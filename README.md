# IP Diagnostic Tool

The IP Diagnostic Tool is an interactive PowerShell script designed to monitor network connectivity for a specified list of IP addresses or hostnames. It performs automated ping tests, identifies DNS or timeout issues, and logs unresponsive targets to a local text file for simplified troubleshooting.

## Features

* **Batch Testing**: Reads multiple target IP addresses or hostnames from a centralized `list.txt` file.
* **Detailed Connection Diagnostics**: Retrieves remote IP addresses and measures round-trip response times in milliseconds (ms).
* **Smart Error Identification**: Categorizes failures specifically as "Request Timed Out" or "Unknown Host (DNS Failure)".
* **Automated Logging**: Records all offline results into `dead_ips.txt` automatically for later review.
* **Interactive Run Modes**:
  * **Single Run**: Performs one complete diagnostic check of the list.
  * **Continuous Mode**: Repeatedly scans the target list every 5 seconds until manually stopped.

## File Structure

* `check.ps1`: The core PowerShell script containing the diagnostic logic and interactive menu.
* `list.txt`: The configuration file where you define the list of IPs or hostnames to be tested (one per line).
* `dead_ips.txt`: An automatically generated output file that logs failed connection attempts.
* `LICENSE`: The project's MIT License file.

## Usage Instructions

### Prerequisites
* Windows PowerShell.
* Ensure `check.ps1` and `list.txt` are located in the same directory.

### Setup
1. Open `list.txt` in any text editor.
2. Add the IP addresses or hostnames you wish to monitor, placing one entry per line. Save the file.

### Running the Tool
1. Open PowerShell and navigate to the directory containing the script.
2. Execute the script by running:
   ```powershell
   .\check.ps1

## Menu Options

Once the initial check is complete, you will be prompted with the following options:

* **`y` (Run again):** Performs a single manual refresh of the IP list.
* **`yy` (Run continuously):** Activates continuous mode, scanning the list every 5 seconds.
  * *Note: To stop continuous mode and return to the menu, press the **'Q'** key.*
* **`n` (Stop):** Ends the script execution.

## Example Output

The script provides a live summary at the end of each scan:
```powershell
Total Successful: {Number of devices online.}
Total Unsuccessful: {Number of devices offline or unreachable.}
