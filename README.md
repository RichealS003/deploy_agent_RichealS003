VIDEO LINK: 


#DEPLOY AGENT (STUDENT ATTENDANCE TRACKER)

A shell script(deploy_agent.sh) that has three features deploy, run and archive.

It is designed to manage the deployment, execution and log archiving of the Student Attendance Tracker python application.

##REPOSITORY STRUCTURE##

Deploy_agent_RichealS003/
├── deploy_agent.sh
├── README.md
└── templates/
    ├── assets.csv
    ├── attendance_checker.py
    └── config.json

##FEATURES & IMPLEMENTATION LOGIC##

1. Deploy the Application (deploy):

#PRE-FLIGHT CHECKS: Verifies that both python3 and zip are installed on the host system using command -v. Fails earlyby exiting the script with a clear error message if they are missing.

#NAMING OF THE INITIAL DIRECTORY: Prompts the user for a project directory name, validating input using strict regex to prevent formatting errors. If the directory already exists, it interactively asks whether to overwrite it or abort safely.

#DIRECTORY & FILE SETUP: Creates the required structure (attendance_tracker_{input}/, reports/, and Helpers/), copies the unmodified attendance_checker.py and config.json from the templates directory and initializes assets.csv.

##Roster Building Options:

Option A: Copies a user specified number of student rows from templates/assets.csv (carrying 4 prior sessions, with total_sessions set to 5).

Option B: Generates a fresh roster from predefined sample arrays, setting initial counts to 0 and adjusting total_sessions to 1.

#PERMISSIONS MANAGEMENT: Restricts permissions using chmod 600 on Helpers/config.json (protecting grading-sensitive thresholds) and applies chmod +x to the Python application to make it executable.

#THRESHOLD CUSTOMIZATION: Offers an interactive prompt to modify warning (default 75) and failure (default 50) attendance thresholds, updating config.json in place safely via sed without altering file structure.

#ROBUST SIGNAL HANDLING:Traps SIGINT (Ctrl+C) and SIGTSTP (Ctrl+Z) during the deployment phase.

On interruption, it instantly bundles partial workspace files into a zip file and deletes dangling folders to maintain workspace cleanliness.

###Contents of the zipped file can be viewed using the command : unzip -l attendance_tracker_{input}_archive.zip where input stands for the name given to the tracker.###


#COMPLETION & TRANSITION: Prints a success message and returns the user to the interactive menu, leaving the project fully structured and ready to be executed via the Run the Application option.



2. Run the Application (run_app):

Locates the deployed project directory and starts attendance_checker.py, handing over terminal controls to the instructor for live interactive attendance marking.



3. Archive Log Files (archive):

Scans the reports/ directory for generated logs (attendance.log and absent.log).

Bundles backups into structured subdirectories (archives/attendance/ and archives/absent/) with system timestamped filenames to ensure traceability and uniqueness.

Includes graceful error handling to manage scenarios where logs do not exist (e.g., no absent log created because zero students were absent).



##HOW TO RUN##

Clone the repository to your local machine:
git clone https://github.com/RichealS003/deploy_agent_RichealS003.git

Change directory to that repository
cd deploy_agent_RichealS003

Run the master script:
./deploy_agent.sh
or
bash deploy_agent.sh

Use the interactive menu prompt to navigate between Deploy the Application, Run the Application, Archive the Log Files, and Quit.

Testing & Verification
Config Validation: Threshold inputs are strictly validated to accept only numeric values between 0 and 100 before applying sed updates.

Interrupt Traps: Tested by triggering Ctrl+C or Ctrl+Z during the directory creation and roster building phases, verifying that partial files are safely zipped and workspace clutter is removed.

Log Archiving: Verified by executing a mock live marking session and running the archive feature to confirm that timestamped logs are correctly stored in their respective archive subdirectories.

