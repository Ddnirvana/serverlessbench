# C-app
The C-app implements a simple RSA key pairs generator.

## Parameter
No parameter is needed

## Return Value
* The generated public key pair
* The generated private key pair
* The start time of the action (timestamp; millisecond)

## How to Deploy
Run `./action_update.sh` in the `./action`

## How to Invoke
Run `./action_update.sh` in the `./action/`

## Test Scripts
* single-cold_warm.sh

    **Usage:**

    ``` bash
    ./single-code_warm [-m <mode>] [-t <loop times>] [-w <warm up times>] [-r <result file>] [-l] [-W] [-R]
    ```
    Invoke the action one by one, and echo the invoking timestamp, starting timestamp and the returning timestamp.

    * mode: can be "warm" or "cold". 
    
      The default mode is "warm"
    
      * warm

        The action invokes the first action to ensure that there's a paused container, and then invoke \<loop times> actions.

      * cold
    
        Invoke \<loop times> actions. Before every action is invoked, stop all the paused runtime containers of the action first.

    * loop times

      The times to invoke the action.

      If the mode is "warm", the default value is 10; 
      
      else, the default value is 3.

    * warm up times

      If the mode is "warm", the action needs to be warmed up. So, the action will firstly be invoked \<warm up times> times.

      The default value is 1.

    * result file

      With the specified file directory, the final result of the test will be appended to the end of the file.
    
    * -l
      
      Output the timestamps to the log.

    * -W

      Warm up only:
      The script only warms up the container and then stops.
      
      *'-R' and '-W' can not be assigned at the same time. -W could only be used in 'warm' mode*

    * -R
      
      Run only:
      The script does not warm up the container.

      This mode requires existing paused containers of this action.

      *'-R' and '-W' can not be assigned at the same time.*

* run.py

    **Usage:**
    ``` bash
    python3 run.py <client number> <looptimes> [<warm up times>]
    ```

    The python script let \<client number> clients invoke the action concurrently, and each client invokes the action \<looptimes> times.
    
    **Output**
    * result.csv

        The invoking timestamp, starting timestamp and the returning timestamp of each activation.
    
    * stdout
        
        The latency and the throughput.

    * eval-result.log

        Append the results to the log.

* eval.sh

    **Usage:**
    ``` bash
    ./eval.sh
    ```
    Run several tests and output a comprehensive result.

    Result log: eval-result.log