#!/usr/bin/env bash

#The first step is setting up the menu. This gives the user the choice of what to do with the script.

deploy() {

	trap 'echo -e "\nDeployment was interrupted. Archiving directory and cleaning up...\n"; zip -r "attendance_tracker_${tracker_name}_archive.zip" "attendance_tracker_$tracker_name"; rm -r "attendance_tracker_$tracker_name"; exit 1' SIGINT

	trap 'echo -e "\nDeployment was interrupted. Archiving directory and cleaning up...\n"; zip -r "attendance_tracker_${tracker_name}_archive.zip" "attendance_tracker_$tracker_name"; rm -r "attendance_tracker_$tracker_name"; exit 1' SIGTSTP



	echo -e "Checking if python and zip are installed.\n"
	#Initially combined checking if both zip and python were installed but then it made it harder to tell exactly which one was installed so decided to separate the two.
	if command -v python3 > /dev/null ; then
		#The code checks if the applications are installed. Now normally using the comman -v prints a path for where the application is located but that was not necessary in this script so the redirection is to prevent it from printing to the screen.
		echo -e "Python($(python3 --version)) is installed. Continuing with the program.\n"
	else
		echo -e "Python isn't installed. Exiting...\n"
		exit 1
		#The code exits the application completely if the aplications are not installed and sends an error message to the terminal.
	fi

	if command -v zip > /dev/null ; then
		echo -e "Zip is installed. $(zip -v | head -n 2 | tail -n 1) Continuing with the program.\n"
	else
		echo -e "Zip isn't installed. Exiting...\n"
		exit 1
	fi

	echo -e "This script creates an attendance tracker and you can choose what name to give to it.\n"

        #Asking user for the name they want to give the tracker.
        read -p "Please enter a name for the tracker: " tracker_name
        #Making sure that the user doesn't cause the script to crash because of unexpected names.
	if [[ $tracker_name =~ ^[-_[:alnum:]]+$ ]]; then

 #Creating the directory but making sure there's a fail safe for if the directory already exists.

        	if [[ -d "attendance_tracker_$tracker_name" ]]; then
			echo -e "\nThis directory already exists.\n"
                	read -p "Do you want to overwrite the information contained in this directory effectively creating a new one (y/n)? " choice
                	case $choice in
                		[Yy] )
                        		echo -e "\nOverwriting information in this directory.\n"
                        		#Deleting the existing directory and creating a new one to effectively overwrite. Because unlike a file, redirecting or moving doesn't have the same overwrite effect on a directory.
                        		rm -r "attendance_tracker_$tracker_name/"
					echo -e "Old directory successfully overwritten.\n"
                        		;;
               			[Nn] )
		      			 #Good so I was thinking that if somebody started deploying the project or the application And it was somehow interrupted so it wasn't fully populated or there are no files or directories in that particular project then the deployment should continue because there's nothing meaning it didn't fully deploy. How to go about that - notes to self.

                        		echo -e "Exiting... No changes made.\n"
					return
                        		;;
                		* )
                        		echo -e "Please choose (y/n).\n"
                        		return
					;;
                	esac
		fi
    	else
		echo -e "Please type a proper name. Only letters, numbers, hyphens and underscores are accepted. No spaces allowed.\n"
		return
	fi
#At first the validation checked if the directory didn't exist and created the directories and populated it but that meant during the overwrite I had to repeat the same block of code, so a little research showed this was a cleaner way to do it. 
	if [[ ! -d "attendance_tracker_$tracker_name" ]]; then
		echo -e "Creating attendance tracker directory...\n"
       		mkdir "attendance_tracker_$tracker_name/"
		echo -e "Attendance tracker directory successfully created.\n"		
		echo -e "Adding python application to the root of the directory...\n"
		cp templates/attendance_checker.py "attendance_tracker_$tracker_name"


		echo -e "Populating directory with required files and directories...\n"
		mkdir "attendance_tracker_$tracker_name/reports" 

		mkdir "attendance_tracker_$tracker_name/Helpers" 
		cp templates/config.json "attendance_tracker_$tracker_name/Helpers"

		touch "attendance_tracker_$tracker_name/Helpers/assets.csv"


		echo -e "Successfully populated.The directory is ready for the next step.\n"


		#The user gets to choose how to build the roster and the code below lets them choose from two options.

		echo -e "You get to choose how to build the roster!\n"
		echo "1. Copy students' data from existing templates directory? OR "
		echo -e "2. Generate a fresh roster?\n"
			
		read -p "How would you like the roster to be built? Select 1 or 2: " roster_choice
		echo -e "\n"

		case $roster_choice in
			"1" )
				read -p "How many students' data do you want to copy? " num_students
				echo -e "\n"
				#Making sure the user only enters a number
				if [[ $num_students =~ ^[[:digit:]]+$ ]] && [[ $num_students -gt 0 ]]; then
					#Making sure there's a fail safe for when the user enters a number that's more than the data available
					#Because the assets.csv file also contains a header, counting the total number of lines will return the header as part of the total so if the user types 8 when there are seven students, the program won't crash but it won't deliver the expected result hence the subtraction below.
					if [[ $num_students -le $(( $(wc -l < ./templates/assets.csv) -1 )) ]]; then
						head -n $(( num_students+1 )) ./templates/assets.csv > "attendance_tracker_$tracker_name/Helpers/assets.csv"
						echo -e "Students' data successfully copied.\n"
					else
						echo -e "Insufficient student data to copy. Please choose a smaller number.\n"
						return
					fi

				else
					echo -e "Please enter a valid number. Number should be greater than zero.\n" 
					return
				fi
			
				;;
			"2" )
				echo -e "Getting ready to generate the fresh roster...\n"
				names=( Charles Veronica Tina Emmanuella Kate Kalinda Immaculate )
				emails=( charles@example.com Veronica@example.com Tina@example.com Emmanuella@example.com Kate@example.com Kalinda@example.com Immaculate@example.com )

				read -p "How many students' data do you want to generate? " num_students
				#Adding header row to the empty assets.csv file
				if [[ $num_students =~ ^[[:digit:]]+$ ]] && [[ $num_students -gt 0 ]]; then

					#Same failsafe for when the number is greater than the data available.
					if [[ $num_students -le ${#names[@]} ]]; then
						echo -e "Email,Names,Attendance Count,Absence Count" > "attendance_tracker_$tracker_name/Helpers/assets.csv"
						#Using a for loop to add the student data to the assets.csv file below the already added header.

						for (( i=0; i<num_students; i++ )); do
							echo "${emails[$i]},${names[$i]},0,0" >> "attendance_tracker_$tracker_name/Helpers/assets.csv"
							#Ensuring total attendance count in config.json is 1 for option B
						done
					else
						echo -e "Insufficient student data to generate. Please choose a smaller number.\n"
						return
					fi
				else
					echo -e "Please enter a valid number. Number should be greater than zero.\n"
					return
				fi


				echo -e "Students' data successfully generated.\n"

				#Making sure total sessions count in option B is 1.
				sed -i 's/ "total_sessions": 5/ "total_sessions": 1/' "attendance_tracker_$tracker_name/Helpers/config.json"
				;;
			* )
				echo -e "Please choose a valid option (1 or 2).\n"
				return
				;;
		esac



       		#Setting the required file permissions.
		chmod +x "attendance_tracker_$tracker_name/attendance_checker.py" 
		if [[ $? -eq 0 ]]; then
			echo -e "Python application's permission successfully updated.\n"
		else
			echo -e "Failed to update the python application's permissions.Please try again.\n"
		fi


		chmod 600 "attendance_tracker_$tracker_name/Helpers/config.json" 
 		if [[ $? -eq 0 ]]; then
			echo -e "Config.json's permissions successfully updated.\n"
		else
			echo -e "Failed to update the config.json file's permissions. Please try again.\n"
		fi

		echo -e "Updated file permissions. Python Application is now executable. Config file permissions restricted.\n"


	fi
		
		
	echo -e "You have the option of updating the attendance alert thresholds (warning- default 75 and failure- default 50).\n"
	read -p "Do you want to update the attendance alert thresholds (y/n)?  " update_choice
	case $update_choice in
		[Yy] )
			read -p "What would you like the new figure for the warning alert to be(please type a number)? " warning_figure
			#Making sure the figure the user provides is greater than or equal to zero and less than 100
			if [[ $warning_figure =~ ^[[:digit:]]+$ ]] && [[ $warning_figure -ge 0 ]] && [[ $warning_figure -le 100 ]]; then
				#making sure the sed command get the value inside the variable to replace the old figure.

				sed -i 's/ "warning": 75/ "warning": '"$warning_figure"'/' "attendance_tracker_$tracker_name/Helpers/config.json"
				#Failsafe for if the sed command fails to update the thresholds.
			        if [[ $? -eq 0 ]]; then
					echo -e "Warning thresholds successfully updated.\n"
				else
					echo -e "Failed to update warning thresholds.\n"
				fi

		       	       
			else
				echo -e "Please type in a number between 0 and 100.\n"
				return
			fi

			read -p "What would you like the new figure for failure alert to be(please type a number)? " failure_figure

 			if [[ $failure_figure =~ ^[[:digit:]]+$ ]] && [[ $failure_figure -ge 0 ]] && [[ $failure_figure -le 100 ]]; then
				#making sure the sed command get the value inside the variable to replace the old text.
			        sed -i 's/ "failure": 50/ "failure": '"$failure_figure"'/' "attendance_tracker_$tracker_name/Helpers/config.json"
				if [[ $? -eq 0 ]]; then
					echo -e "Failure thresholds successfully updated.\n"
				else
					echo -e "Failed to update failure thresholds.\n"
				fi
		       	       
			else
				echo -e "Please type in a number between 0 and 100.\n"
				return

			fi
			;;

		[Nn] )
			echo -e "Continuing with the program. No changes made.\n"
			;;
		* )
			echo -e "Please choose a valid response (y/n).\n"
			return
			;;
	esac

	echo -e "Application successfully deployed!\n"
	echo -e "Ready to run the python program now.\n"
               


}


run_app() {
	read -p "Please enter the name of the tracker you want to run: " tracker_name
	if [[ -d "attendance_tracker_$tracker_name" ]]; then
		echo -e "Starting the python application...\n"
		cd "attendance_tracker_$tracker_name"
		python3 attendance_checker.py
		cd ..
	else
		echo -e "This directory does not exist.\n"
		echo -e "Please deploy the application first.\n"
	fi
}


archive() {
	echo -e "This part of the application archives each existing log into its own directory.\n"
	read -p "Please enter the name of the tracker you want to archive: " tracker_name
	if [[ -d "attendance_tracker_$tracker_name" ]]; then
		if [[ ! -d "attendance_tracker_$tracker_name/archives" ]]; then
			echo -e "Creating archive directory that will hold the individual directories for the logs...\n"
			mkdir "attendance_tracker_$tracker_name/archives"
		else
			echo -e "Archive directory already exists. Moving on...\n"
		fi
	else
		echo -e "Directory doesn't exsit. Please deploy the application first and run the program.\n"
		return
	fi

	#Checking whether reports/attendance.log and reports/absent.log exist after the run.
	#The reports directory should exist after the run, but how do I actually check that they've run the program without relying on the logs in the report directory? Reminder for me to find out.

	#Creating individaul directories for both attendance and absence.
	echo -e "Checking whether the logs exists in the reports directory after the program run...\n"
	if [[ -f "attendance_tracker_$tracker_name/reports/attendance.log" ]] || [[ -f "attendance_tracker_$tracker_name/reports/absent.log" ]]; then
		echo -e "The logs exist.\n"
	else
		echo -e "No logs available. Please make sure you have deployed and run the program.\n"
		return
	fi
	
	if [[ -f "attendance_tracker_$tracker_name/reports/attendance.log" ]]; then

#Realised that if a user had run the archive function already the attendance or absent directory will already exist so there will be an error. Had to account for that, hence the checkpoints.

		if [[ -d "attendance_tracker_$tracker_name/archives/attendance" ]]; then
 			read -p "Do you want to overwrite the information contained in the attendance directory (y/n)? " choice
                	case $choice in
               			 [Yy] )
                        	 	echo -e "\nOverwriting information in the attendance directory...\n"
                        		rm -r "attendance_tracker_$tracker_name/archives/attendance"
					echo -e "Old attendance directory successfully overwritten.\n"
                       			;;

               			 [Nn] )
                        		echo -e "Exiting. No changes made.\n"
					return
                        		;;
                		 * )
                        		echo -e "Please choose (y/n).\n"
					return
                        		;;
               	 	esac
		fi

		if [[ ! -d "attendance_tracker_$tracker_name/archives/attendance" ]]; then

			echo -e "Creating the attendance directory in the archives directory...\n"

	        	mkdir "attendance_tracker_$tracker_name/archives/attendance"
			echo -e "Preparing to archive the attendance logs...\n"
			cp "attendance_tracker_$tracker_name/reports/attendance.log" "attendance_tracker_$tracker_name/archives/attendance/attendance_$(date +"%Y%m%d_%H%M%S").log"
			echo -e "Attendance logs successfully archived. Filepath for attendance logs: $(realpath "attendance_$(date +"%Y%m%d_%H%M%S").log")\n"
		fi

	       	
		if [[ -f "attendance_tracker_$tracker_name/reports/absent.log" ]]; then
			if [[ -d "attendance_tracker_$tracker_name/archives/absent" ]]; then
 				read -p "Do you want to overwrite the information contained in the absent directory (y/n)? " choice
                		case $choice in
               			 	[Yy] )
                        	 		echo -e "\nOverwriting information in the absent directory...\n"
			       			#Deleting the existing directory and creating a new one to effectively overwrite. Because unlike a file, redirecting or moving doesn't have the same overwrite effect on a directory.
                        			rm -r "attendance_tracker_$tracker_name/archives/absent"
						echo -e "Old  absent directory successfully overwritten.\n"
                       				;;
               			 	[Nn] )
                        			echo -e "Exiting. No changes made.\n"
						return
                        			;;
                		 	* )
                        			echo -e "Please choose (y/n).\n"
						return
                        			;;
               	 		esac
			fi
			

			echo -e "Creating absent directory in the archive directory...\n"
			mkdir "attendance_tracker_$tracker_name/archives/absent"
			echo -e "Preparing to archive the absent logs...\n"
			cp "attendance_tracker_$tracker_name/reports/absent.log" "attendance_tracker_$tracker_name/archives/absent/absent_$(date +"%Y%m%d_%H%M%S").log"
			echo -e "Absent logs successfully archived. File path for absent logs: $(realpath "absent_$(date +"%Y%m%d_%H%M%S").log")\n"

		else
			echo -e "No absent logs available. Please make sure you have deployed and run the program.\n"
		fi
	else
		echo -e "Something is wrong. No logs available. Please make sure to deploy and run the program first.\n"
	fi
	echo -e "Archive successful. Congrats!\n"



}


PS3="Please select one of the following (1-4) to decide what to with the program (1.Deploy 2.Run 3.Archive 4.Quit): "
select choice in "Deploy the Application" "Run the Application" "Archive the Log Files" "Quit"; do
	case $choice in
		"Deploy the Application" )
			deploy
			;;

		"Run the Application" )
			run_app
			;;

		"Archive the Log Files" )
			archive
			;;

		"Quit" ) 
			echo -e "Quitting the application..."
			break
			;;
		* ) 
			echo -e "Please select a valid option"
			;;
	esac
done
