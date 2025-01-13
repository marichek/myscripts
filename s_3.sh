#!/bin/bash

# Directory containing thread dump files
INPUT_DIR="/Users/marik/Documents/Crossjoin/crossjoin_td_test"
OUTPUT_FILE="$INPUT_DIR/output_3.csv"
DEBUG_FILE="$INPUT_DIR/debug_3.txt"  # Define the debug output file

# Initialize the CSV output file with headers
echo "Filename,Timestamp,Thread Type,Thread Name,Thread State,LAST_CALL,LAST_CUSTOM_CALL, Thread ID (Hex),Native ID,Priority,OS Thread ID,CPU Usage,Elapsed Time,TID,NID,Other Value" > "$OUTPUT_FILE"

# Clear previous debug file content
> "$DEBUG_FILE"

# Process each thread dump file
for file in "$INPUT_DIR"/tuxedo-adapter-service-primary-7b78c65dc8*; do
    if [[ -f "$file" ]]; then
        # Extract filename and timestamp
        FILENAME=$(basename "$file")
        TIMESTAMP=$(grep -m 1 -E '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' "$file")

      
        echo "Processing $FILENAME with timestamp $TIMESTAMP" >> "$DEBUG_FILE"


        awk '/^"[^"]+"/,/^$/' "$file" | while read -r line; do

            THREAD_NAME=""
            THREAD_TYPE=""
            THREAD_STATE=""
            STATE=""
            LAST_CALL=""
            LAST_CUSTOM_CALL=""
            THREAD_ID_HEX=""
            NATIVE_ID=""
            PRIORITY=""
            OS_THREAD_ID=""
            CPU_USAGE=""
            ELAPSED=""
            TID=""
            NID=""
            OTHER_VALUE=""

            # Debug: Check if line contains thread data
            echo "Parsing line: $line" >> "$DEBUG_FILE"

            # Extract Thread Name and Type
            if [[ $line =~ ^\"([^\"]+)\" ]]; then
                 THREAD_NAME=${BASH_REMATCH[1]}
                # For thread names starting with "http-nio-", extract the prefix up to "exec-"
                if [[ $THREAD_NAME =~ ^(http-nio-[0-9]+) ]]; then
                     THREAD_TYPE=${BASH_REMATCH[1]}  # Match http-nio-7012
                else
                    THREAD_TYPE=$THREAD_NAME  # Default: Thread Type = Thread Name
                fi
                  echo " Captured THREAD_NAME: $THREAD_NAME" >> "$DEBUG_FILE" 
                  echo " Captured THREAD_TYPE: $THREAD_TYPE" >> "$DEBUG_FILE" 
            fi

            # Extract Thread State (handles different formats)
          #  if [[ $line =~ java\.lang\.Thread\.State:\ (.*) ]]; then
          #      THREAD_STATE="${BASH_REMATCH[1]}"  
           # fi

            if [[ $line =~ java\.lang\.Thread\.State:\ (.*) ]]; then
           #     THREAD_STATE="\"${BASH_REMATCH[0]}\""  
           THREAD_STATE="${BASH_REMATCH[1]}"
           THREAD_STATE=$(echo "$THREAD_STATE" | sed 's/^ *//;s/ *$//')

                            echo " Captured Thread State: $THREAD_STATE" >> "$DEBUG_FILE"
               # STATE="$THREAD_STATE   "
                echo "STATE: $STATE" >> "$DEBUG_FILE"
            fi

            # Debug: Check if the state was captured
          #  echo "Thread State: $THREAD_STATE" >> "$DEBUG_FILE"

            # Extract Priority
            if [[ $line =~ prio=([0-9]+) ]]; then
                PRIORITY=${BASH_REMATCH[1]}
                 echo " Captured PRIORITY: $PRIORITY" >> "$DEBUG_FILE" 
            fi

            # Extract Thread ID (Hexadecimal)
            if [[ $line =~ tid=0x([0-9a-fA-F]+) ]]; then
                THREAD_ID_HEX=${BASH_REMATCH[1]}
                echo " Captured THREAD_ID_HEX: $THREAD_ID_HEX" >> "$DEBUG_FILE" 
            fi

            # Extract Native ID
            if [[ $line =~ nid=0x([0-9a-fA-F]+) ]]; then
                NATIVE_ID=$((16#${BASH_REMATCH[1]})) # Convert hex to decimal
                 echo " Captured NATIVE_ID: $NATIVE_ID" >> "$DEBUG_FILE" 
            fi

            # Extract OS Thread ID
            if [[ $line =~ nid=0x[0-9a-fA-F]+[[:space:]]+\[0x([0-9a-fA-F]+)\] ]]; then
                OS_THREAD_ID=$((16#${BASH_REMATCH[1]})) # Convert hex to decimal
                 echo " Captured OS_THREAD_ID: $OS_THREAD_ID" >> "$DEBUG_FILE" 
            fi

            # Extract CPU Usage
            if [[ $line =~ cpu=([0-9\.]+)ms ]]; then
                CPU_USAGE=${BASH_REMATCH[1]}
                 echo " Captured CPU usage: $CPU_USAGE" >> "$DEBUG_FILE" 
            fi

            # Extract Elapsed time
            #if [[ $line =~ elapsed=([0-9\.]+)s ]]; then
            if [[ $line =~ elapsed=([0-9]+\.[0-9]+)s ]]; then
                ELAPSED="${BASH_REMATCH[1]}"
                 echo "Captured Elapsed time: $ELAPSED" >> "$DEBUG_FILE"    
            fi

            # Extract TID
            if [[ $line =~ tid=0x([0-9a-fA-F]+) ]]; then
                TID=${BASH_REMATCH[1]}
                  echo "Captured TID: $TID" >> "$DEBUG_FILE"    
            fi

            # Extract NID
            if [[ $line =~ nid=0x([0-9a-fA-F]+) ]]; then
                NID=${BASH_REMATCH[1]}
                   echo "Captured NID: $NID" >> "$DEBUG_FILE"    
            fi

              # Look for the last method in the stack trace
            if [[ $line =~ at\ (.*)\.([a-zA-Z0-9_]+)\(([a-zA-Z0-9_\.]+)\) ]]; then
                LAST_CALL="${BASH_REMATCH[0]}"
                   echo "Captured LAST_CALL: $LAST_CALL" >> "$DEBUG_FILE"    
            fi

            # Look for the last custom method (methods specific to your codebase)
            if [[ $line =~ at\ com\.crossjointest\.cbs\..* ]]; then
                LAST_CUSTOM_CALL="${line}"
                   echo "Captured LAST_CUSTOM_CALL: $LAST_CUSTOM_CALL" >> "$DEBUG_FILE"    
            
            fi
            


            # Extract other information
        #    if [[ $line =~ \[([^\]]+)\] ]]; then
         #       OTHER_VALUE=${BASH_REMATCH[1]}
          #  fi

            # If thread data is found, append it to CSV
           # if [[ -n $FILENAME ]]; then
             #   echo "$FILENAME,$TIMESTAMP,$THREAD_TYPE,$THREAD_NAME,$THREAD_STATE,$STATE,$THREAD_ID_HEX,$NATIVE_ID,$PRIORITY,$OS_THREAD_ID,$CPU_USAGE,$ELAPSED,$TID,$NID,$OTHER_VALUE" >> "$OUTPUT_FILE"
            #if [[ -z "$THREAD_STATE" ]]; then
            #     THREAD_STATE="N/A"
          #  fi
          echo "\"$FILENAME\",\"$TIMESTAMP\",\"$THREAD_TYPE\",\"$THREAD_NAME\",\"$THREAD_STATE\",\"$LAST_CALL\",\"$LAST_CUSTOM_CALL\",\"$THREAD_ID_HEX\",\"$NATIVE_ID\",\"$PRIORITY\",\"$OS_THREAD_ID\",\"$CPU_USAGE\",\"$ELAPSED\",\"$LOCK_INFO\"" >> "$OUTPUT_FILE"
           echo "written to CSV: \"$FILENAME\",\"$TIMESTAMP\",\"$THREAD_TYPE\",\"$THREAD_NAME\",\"$THREAD_STATE\",\"$LAST_CALL\",\"$LAST_CUSTOM_CALL\",\"$THREAD_ID_HEX\",\"$NATIVE_ID\",\"$PRIORITY\",\"$OS_THREAD_ID\",\"$CPU_USAGE\",\"$ELAPSED\",\"$LOCK_INFO\"" >> "$DEBUG_FILE"
         #   fi
        done
    fi
done

echo "Parsing complete. Output saved to $OUTPUT_FILE."
