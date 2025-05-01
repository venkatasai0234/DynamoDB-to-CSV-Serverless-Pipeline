1. Authenticate with your AWS account using CLI. You should have root privileges
2. Run setup.sh, which will get you set up with the necessary resources. It may take up to 
   20 minutes for the ddb to finish exporting to S3.
   Read the script and make edits to the script. Blindly running it will not work. The script might report errors.
   You are expected to fix the errors. 
3. Create a file named template.yaml. This will be the file you will use to set up the infrastructure. 
   This is where most of the work lies. 
4. Use deploy_stack.sh to deploy any resources declared in template.yaml. 
5. Write collate.sh to execute the Lambda, download the csv files to a temp folder, and collate them.
