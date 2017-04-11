#!/bin/sh


main () {
    command=$1;
    fileName=$2;
    
    case $command in
		 -c) 
			rm -rf ./Verification
			mkdir "Verification"
			touch ./Verification/"$fileName.txt"
			echo "$fileName.txt" "has been created"
			function_c
			break ;; 
		 -o) 
		    rm -f ./Verification/"Verification.txt"
		    function_o
			break ;;
		  *) echo "Unknown command was entered" 
		   break ;;
	 esac
}

function_c (){
	ls -Rlni ./Desktop | awk '/:$/&&f{s=$0;f=0} /:$/&&!f{sub(/:$/,"");s=$0;f=1;next} NF&&f{ print s"/ "$0 }'| grep '.\{40\}' | while read line
	do
			fileNamePath=`echo $line | awk '{print $11}'`;
			fileUniqueID=`echo $line | awk '{print $2}'`;
			filePath=`find -inum $fileUniqueID`;
			fileType=`stat --format '%F' $filePath`;
			accessMode=`echo $line | awk '{print $3}'`;
			ownerID=`echo $line | awk '{print $5}'`;
			groupID=`echo $line | awk '{print $6}'`;
			blockSize=`echo $line | awk '{print $7}'`;
			lastModified=`stat -c %y $filePath`;
			statusChange=`stat -c %z $filePath`;

			metaHash=`echo $fileNamePath $fileUniqueID $filePath $fileType $accessMode $ownerID $groupID $blockSize $lastModified $statusChange | md5`;
			if [ "$fileType" = "regular file" ] || [ "$fileType" = "regular empty file" ];
			then
				Hash=`find $filePath -type f -print0 | xargs -0 md5`;
			else
				Hash="Not Applicable";
			fi
			
			echo "File Type:" $fileType | cat >> ./Verification/"$fileName.txt"
			echo "File ID:" $fileUniqueID | cat >> ./Verification/"$fileName.txt"
			echo "File Path:" $filePath | cat >> ./Verification/"$fileName.txt"
			echo "File Name:" $fileNamePath | cat >> ./Verification/"$fileName.txt"
			echo "Access Mode:" $accessMode | cat >> ./Verification/"$fileName.txt"
			echo "Owner ID:" $ownerID | cat >> ./Verification/"$fileName.txt"
			echo "Group ID:" $groupID | cat >> ./Verification/"$fileName.txt"
			echo "Block Size:" $blockSize | cat >> ./Verification/"$fileName.txt"
			echo "Last Modified:" $lastModified | cat >> ./Verification/"$fileName.txt"
			echo "Status Change:" $statusChange | cat >> ./Verification/"$fileName.txt"
			echo "File MD5:" $Hash | cat >> ./Verification/"$fileName.txt"
			echo "Meta MD5:" $metaHash | cat >> ./Verification/"$fileName.txt"
			echo "" | cat  >> ./Verification/"$fileName.txt"
	done
	cat ./Verification/"$fileName.txt"
}

function_o (){
	# remove difference file
	rm -f ./Verification/DifferenceOuput.txt
	echo "Comparing Files...."
	# Compare inodes to that in the -c file to find new files
	ls -Rlni ./Desktop | awk '{printf $1 "\n"}'| grep -e "^[!0-9]" |sed 's/[^0-9]*//g'| sed '/^\s*$/d' | while read line
	do
		fileUniqueID=`echo $line | awk '{print $1}'`;
	if grep -q $fileUniqueID ./Verification/"$fileName.txt"; then 
		filePathFound=`find -inum $fileUniqueID`;
	else
		filePathFound=`find -inum $fileUniqueID`;
		echo "___________________________________________\n"
		echo "New file detected $filePathFound"
		echo "New file detected $filePathFound" | cat >> ./Verification/DifferenceOuput.txt
		echo "File has these values" $(ls -lni $filePathFound)
		echo "File has these values" $(ls -lni $filePathFound) | cat >> ./Verification/DifferenceOuput.txt
		echo "___________________________________________\n"
	fi 
	
	done
	#  Read through -c file and store a single files variables to be compared
	cat ./Verification/"$fileName.txt" | while read line
	do
		fileLine1=`echo $line | awk '{print $1" "$2}'`;
		if [ "$fileLine1" = "File Type:" ]; then SnapShotFileType=`echo $line | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`; fi
		if [ "$fileLine1" = "File ID:" ]; then SnapShotFileID=`echo $line | awk '{print $3}'`; fi
		if [ "$fileLine1" = "File Path:" ]; then SnapShotFilePath=`echo $line | awk '{print $3}'`; fi
		if [ "$fileLine1" = "File Name:" ]; then SnapShotFileName=`echo $line | awk '{print $3}'`; fi
		if [ "$fileLine1" = "Access Mode:" ]; then SnapShotFileAccessMode=`echo $line | awk '{print $3}'`; fi
		if [ "$fileLine1" = "Owner ID:" ]; then SnapShotFileOwnerID=`echo $line | awk '{print $3}'`;  fi	
		if [ "$fileLine1" = "Group ID:" ]; then SnapShotFileGroupID=`echo $line | awk '{print $3}'`;  fi	
		if [ "$fileLine1" = "Block Size:" ]; then SnapShotBlockSize=`echo $line | awk '{print $3}'`;  fi	
		if [ "$fileLine1" = "Last Modified:" ]; then SnapShotLastMod=`echo $line | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`;  fi	
		if [ "$fileLine1" = "Status Change:" ]; then SnapShotFileStatChange=`echo $line | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`; fi	

		if [ "$fileLine1" = "File MD5:" ]; then SnapShotFileMD5=`echo $line | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`;  fi
		if [ "$fileLine1" = "Meta MD5:" ]; then SnapShotFileMETAMD5=`echo $line | awk '{for (i=3; i<NF; i++) printf $i " "; print $NF}'`; fi
     	if [ "$line" = "" ]; 
     	then 
     		search=`find ./Assignment2/ -maxdepth 1000 -inum $SnapShotFileID`; #make sure that file exists and hasnt been deleted
     		if [ "$search" = "" ];then echo "$SnapShotFilePath is missing and likely destroyed" | cat >> ./Verification/DifferenceOuput.txt ; 
     		else
	     		fileNamePath=`find -inum $SnapShotFileID | xargs basename`;
	     		fileUniqueID=$SnapShotFileID
				filePath=`find -inum  $SnapShotFileID`;
				fileType=`stat --format '%F' $filePath`;
				accessMode=`stat -c '%A' $filePath`;
				ownerID=`stat -c '%u' $filePath`;
				groupID=`stat -c '%g' $filePath`;
				blockSize=`stat -c '%s' $filePath`;
				lastModified=`stat -c %y $filePath`;
				statusChange=`stat -c %z $filePath`;

				metaHash=`echo "$fileNamePath $fileUniqueID $filePath $fileType $accessMode $ownerID $groupID $blockSize $lastModified $statusChange" | md5`;
		

			
		    if [ "$fileType" = "regular file" ] || [ "$fileType" = "regular empty file" ];
			then
				Hash=`find $filePath -type f -print0 | xargs -0 md5`;
			else
				Hash="Not Applicable";
			fi
			# Write the latest values to -o file 
				echo "File Type:" $fileType | cat >> ./Verification/"Verification.txt"
				echo "File ID:" $SnapShotFileID | cat >> ./Verification/"Verification.txt"
				echo "File Path:" $filePath | cat >> ./Verification/"Verification.txt"
				echo "File Name:" $fileNamePath | cat >> ./Verification/"Verification.txt"
				echo "Access Mode:" $accessMode | cat >> ./Verification/"Verification.txt"
				echo "Owner ID:" $ownerID | cat >> ./Verification/"Verification.txt"
				echo "Group ID:" $groupID | cat >> ./Verification/"Verification.txt"
				echo "Block Size:" $blockSize | cat >> ./Verification/"Verification.txt"
				echo "Last Modified:" $lastModified | cat >> ./Verification/"Verification.txt"
				echo "Status Change:" $statusChange | cat >> ./Verification/"Verification.txt"
	
				echo "File MD5:" $Hash | cat >> ./Verification/"Verification.txt"
				echo "Meta MD5:" $metaHash | cat >> ./Verification/"Verification.txt"
				echo "" | cat  >> ./Verification/"Verification.txt"
				
			    metaHash2=`echo $metaHash| awk '{print $1}'`;
		      	Hash2=`echo $Hash| awk '{print $1}'`;
		      	SnapShotFileMETAMD52=`echo $SnapShotFileMETAMD5 | awk '{print $1}'`;
		      	SnapShotFileMD52=`echo $SnapShotFileMD5 | awk '{print $1}'`;
		      	#cat ./Verification/"Verification.txt"
		      	
			    # Use these fields to check if the file inode has been reused  	
				if [ ! "$lastModified" = "$SnapShotLastMod" ] && [ ! "$statusChange" = "$SnapShotFileStatChange" ] && [ ! "$metaHash2" = "$SnapShotFileMETAMD52" ] && [ ! "$Hash2" = "$SnapShotFileMD52" ];
				then
					echo "\n$SnapShotFilePath //-----MAY HAVE BEEN DESTROYED AND REPLACED OR COMPROMISED A GREAT DEAL-----//" | cat >> ./Verification/DifferenceOuput.txt
					echo "$SnapShotFilePath may have been destroyed and replaced with a different file using the inode of $SnapShotFileID and named $fileNamePath" | cat >> ./Verification/DifferenceOuput.txt ; 
				    if [ ! "$fileNamePath" = "$SnapShotFileName" ]; then echo "$SnapShotFilePath was renamed From $SnapShotFileName to $fileNamePath" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$filePath" = "$SnapShotFilePath" ]; then echo "$SnapShotFilePath Path Changed From $SnapShotFilePath to $filePath" | cat >>./Verification/DifferenceOuput.txt; fi     
					if [ ! "$fileType" = "$SnapShotFileType" ]; then echo "$SnapShotFilePath File Typed Changed From $SnapShotFileType to $fileType" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$accessMode" = "$SnapShotFileAccessMode" ]; then echo "$SnapShotFilePath Access Mode Changed From $SnapShotFileAccessMode to $accessMode" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$ownerID" = "$SnapShotFileOwnerID" ]; then echo "$SnapShotFilePath Owner Id has Changed From $SnapShotFileOwnerID to $ownerID" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$groupID" = "$SnapShotFileGroupID" ]; then echo "$SnapShotFilePath Group Id has Changed From $SnapShotFileGroupID to $groupID" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$blockSize" = "$SnapShotBlockSize" ]; then echo "$SnapShotFilePath Block Size Changed From $SnapShotBlockSize to $blockSize " | cat >> ./Verification/DifferenceOuput.txt; fi
					echo "$SnapShotFilePath Modification Time Changed From $SnapShotLastMod to $lastModified" | cat >> ./Verification/DifferenceOuput.txt;
					echo "$SnapShotFilePath Status Change From $SnapShotFileStatChange to $statusChange" | cat >> ./Verification/DifferenceOuput.txt;
					echo "$SnapShotFilePath MetaHash been changed From $SnapShotFileMETAMD52 to $metaHash2" | cat >> ./Verification/DifferenceOuput.txt;
					echo "$SnapShotFilePath Integrity has been changed $SnapShotFileMD52 to $Hash2 \n" | cat >> ./Verification/DifferenceOuput.txt;
				else #print changes
					if [ ! "$fileNamePath" = "$SnapShotFileName" ]; then echo "$SnapShotFilePath was renamed From $SnapShotFileName to $fileNamePath" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$filePath" = "$SnapShotFilePath" ]; then echo "$SnapShotFilePath Path Changed From $SnapShotFilePath to $filePath" | cat >>./Verification/DifferenceOuput.txt; fi     
					if [ ! "$fileType" = "$SnapShotFileType" ]; then echo "$SnapShotFilePath File Typed Changed From $SnapShotFileType to $fileType" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$accessMode" = "$SnapShotFileAccessMode" ]; then echo "$SnapShotFilePath Access Mode Changed From $SnapShotFileAccessMode to $accessMode" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$ownerID" = "$SnapShotFileOwnerID" ]; then echo "$SnapShotFilePath Owner Id has Changed From $SnapShotFileOwnerID to $ownerID" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$groupID" = "$SnapShotFileGroupID" ]; then echo "$SnapShotFilePath Group Id has Changed From $SnapShotFileGroupID to $groupID" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$blockSize" = "$SnapShotBlockSize" ]; then echo "$SnapShotFilePath Block Size Changed From $SnapShotBlockSize to $blockSize " | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$lastModified" = "$SnapShotLastMod" ]; then echo "$SnapShotFilePath Modification Time Changed From $SnapShotLastMod to $lastModified" | cat >> ./Verification/DifferenceOuput.txt; fi
					if [ ! "$statusChange" = "$SnapShotFileStatChange" ]; then echo "$SnapShotFilePath Status Change From $SnapShotFileStatChange to $statusChange" | cat >> ./Verification/DifferenceOuput.txt; fi
		     		if [ ! "$metaHash2" = "$SnapShotFileMETAMD52" ]; then echo "$SnapShotFilePath MetaHash been changed From $SnapShotFileMETAMD52 to $metaHash2" | cat >> ./Verification/DifferenceOuput.txt; fi
		     		if [ ! "$Hash2" = "$SnapShotFileMD52" ]; then echo "$SnapShotFilePath Integrity has been changed $SnapShotFileMD52 to $Hash2" | cat >> ./Verification/DifferenceOuput.txt; fi
		     	fi
	     	fi 
     	fi
	done
	
		file="./Verification/DifferenceOuput.txt";
	if [ ! -f "$file" ]; 
	then 
		echo "___________________________________________\n"
		echo "         No Files have been changed          "
		echo "___________________________________________\n"
		echo "No Files have been changed" |	cat >> ./Verification/DifferenceOuput.txt
	else
		echo "___________________________________________\n"
		echo "The Lines Below State What Has Been Changed"
		echo "___________________________________________\n"
		cat ./Verification/DifferenceOuput.txt
	fi
}

main $1 $2

