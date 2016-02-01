# pull_agent

Deploys your code!

## Usage

    check-in.rb <environment> <payload> [options]
    
    [options]
    --help : Displays this help
    
    <environment> : (required) the environment to deploy. possible values: production, staging, test, dev, engagement
    
        <payload> : (required) the payload (repository) to deploy. 
                    Possible values: pardot, pithumbs, realtime-frontend, workflow-stats, murdoc
    



## Rough Approximation of Functionality

- Pull Agent "checks in" on a regular interval (check-in.rb; lib/strategies/fetch/*.rb)
- Pull Agent compares version pulled from check-in to version currently deployed
- If needed, Pull Agent performs a "deploy" of a new "payload" (downloads a new file into place; lib/strategies/deploy/*.rb)
- If new payload deployed, an "environment" specified action takes place (lib/environments/*.rb)