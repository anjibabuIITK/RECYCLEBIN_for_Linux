#    <============ RBIN ===========>
#        Recyclebin for Linux

 **Authour:**
 
    Anji Babu Kapakayala
	  IIT Kanpur, India.

**Laungauge:** Shell/Bash

**Install**:    

    Place rbin in /usr/bin to be used as executble.

 **Description:** 
	
    RBIN is a software which acts as a RECYCLEBIN" to delete and restore the files in Linux.
    Restores the file/directory to its original location.And gives flexibility to user to ON
    autodeletion feature which deletes the files perminantly for those deletion date is more 
    than 30 days.  

 **Features:**
    
    rbin                 ---> main excutable and deletes given files
    rbin -d/--del        ---> Deletes the files or Directories
    rbin -r/--restore    ---> Restores the given files.
    rbin -e/--emptybin   ---> Will empty the recyclebin
    rbin --SetAutoclean  ---> Options: on , off, Period_of_days to clean the bin
    rbin -h/--help       ---> Prints the information about rbin.
    

 **Directories:**
       
    /home/user/recyclebin          ---> Place to store the deleted files
    /home/user/recyclebin/.cache   ---> Contains the information about deleted files 
	                                    		(date of deletion & original location)
 **Examples:**
 
    rbin *               ---> Deletes all files from current directory.
    rbin -r *            ---> Restores all files from recyclebin.
    rbin -f *            ---> Removes all files perminantly from current directory.
    rbin file1           ---> Deletes the file1
    rbin -r file1        ---> Restore the file1
    rbin -e              ---> Makes recyclebin empty.
    rbin anji_*          ---> Deletes all files starts with anji_
    
    Works well with wildcards like, *, file_* 
    
# <==============================>
**Cheers!**

**Anji Babu Kapakayala**

**17/03/2021**
