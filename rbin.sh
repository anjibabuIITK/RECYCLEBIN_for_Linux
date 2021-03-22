
#----------------------------------------------------------------------------#
#    <========================== RBIN =============================>         #
#	            A command-line Recyclebin for Linux	            	     #
#----------------------------------------------------------------------------#
#
# Authour: Anji Babu Kapakayala
#          IIT Kanpur, India.
#          (anjibabu480@gmail.com)
#
# Laungauge: Shell/bash
#
#
# Installation:
#
#      Download the executable rbin
#      Change the permissions (chmod 777 rbin)
#      Move to /usr/bin
#      rbin -h [ for details ]
#
# Description: 
#	
#	RBIN is a software which acts as a RECYCLEBIN" to delete and restore the files in Linux.
#       Restores the selected file/directory to its original location. And deletes the files 
#       perminantly whose deletion date is more than 30 days.  
#
# Features:
#    
#       rbin                 ---> main excutable
#       rbin -d/--del        ---> Deletes the files or Directories
#       rbin -r/--restore    ---> Restores the given files.
#       rbin -e/--emptybin   ---> Will empty the recyclebin
#       rbin --SetAutoclean  ---> Options: on , off, Period_of_days to clean the bin
#       rbin -h/--help       ---> Prints the information about rbin.
#       rbin -f/--force      ---> Deletes the given file perminantly
#       rbin -l/--list       ---> Lists the contents in Recyclebin along with the age from the day of deletion.
#
#
# Directories:
#       
#       recyclebin          ---> Place to store the deleted files
#       recyclebin/.cache   ---> Contains the information about deleted files (date of deletion & path)
#
#
#!/bin/bash
#----------------------------------------------------------------------------#
# Defining text colors
red=`tput setaf 1`
grn=`tput setaf 2`
ylw=`tput setaf 3`
blu=`tput setaf 4`
pur=`tput setaf 5`
rst=`tput sgr0`
bold=`tput bold`
#----------------------------------------------------------------------------#
bin="$HOME/recyclebin"
cache="$HOME/recyclebin/.cache"
rbinrc="$HOME/.rbinrc"
# if $bin doesn't exist, create
if [ ! -d "$bin" ]; then
# echo "$bin exist."
#else
 echo "$bold$grn $bin $rst$bold Created.$rst"
 mkdir -p $bin
 touch $cache $rbinrc
 cat >>$rbinrc<<EOF
 AUTO_CLEAN=OFF
 EXPIRY_DAYS=30
EOF
fi
#----------------------------------------------------------------------------#
# Function to move files to recyclebin
function delete() {
if [[ ( -f "$1" ) || ( -d "$1" ) ]]; then
   if [[ ( -f "$bin/$1" ) || ( -d "$bin/$1" ) ]]; then
   mv $bin/$1 $bin/$1.old
   sed -i "s/$1:/$1.old:/g" $cache
   fi
   UpdateCache $1
   mv  $1 $bin

else
   echo "$bold$red rbin$rst$bold: --->$ylw $1$rst$bold not found.$rst"
fi
}
#----------------------------------------------------------------------------#
# Function to delete the files perminantly.
function Remove_Perminant() {
if [[ ( -f "$1" ) || ( -d "$1" ) ]]; then
  current_dir=`pwd`
#--->
  if [[ "$current_dir" == "$bin" ]];then
  rm -rf $1
  sed -i "/$1:/d" $cache
  else
#    read -p "This action will perminantly remove the files. Press 'y' to continue [y/n] ? : " option
#    if [[ ( "$option" == "y" ) || ( "$option" == "yes" ) ]];then 
       rm -rf $1
#    fi
  fi
#<---
   echo "$bold$red rbin$rst$bold: --->$ylw $1$rst$bold has deleted perminantly.$rst"
else
   echo "$bold$red rbin$rst$bold: --->$ylw $1$rst$bold not found.$rst"
fi
}
#----------------------------------------------------------------------------#
# Function to empty the recyclebin
function EmptyBin() {
  current_dir=`pwd`
#--->
 if [[ "$current_dir" == "$bin" ]];then
    read -p "$bold$red Are you sure want to empty the Recyclebin [$rst$bold y/n $rst$red] ? :$rst " option
    if [[ "$option" == "y" ]];then 
    rm -rf *
    rm $cache
    echo "$bold$red rbin$rst$bold: --->$ylw Recyclebin is empty.$rst"
    else
    echo "$bold$red rbin$rst$bold: --->$ylw Recyclebin is NOT empty.$rst"
    fi
 else
    echo "$bold$red rbin$rst$bold: --->$ylw The current direcory is NOT a Recyclebin.$rst"
 fi
}
#----------------------------------------------------------------------------#
# Function to restore the deleted files from recyclebin.
function Restore() {
   current_dir=`pwd`
   file=$1
   original_path=`grep " $file:" $cache|cut -d ":" -f 2`
#--->
if [[ "$current_dir" == "$bin" ]];then

   if [[ ( -f "$1" ) || ( -d "$1" ) ]]; then
      mv $bin/$file $original_path
      if [ "$?" == "0" ];then
      sed -i "/$1:/d" $cache
      fi
#      echo "rbin: [restored] $file ------>  $original_path"
      echo "$bold$red rbin$rst$bold:[$grn Restored $rst]$bold $file          ---> $original_path $rst"
   else
   echo "$bold$red rbin$rst$bold: --->$ylw $1$rst$bold not found.$rst"
   fi
else
    echo "$bold$red rbin$rst$bold: --->$ylw The current direcory is NOT a Recyclebin.$rst"
fi
}
#----------------------------------------------------------------------------#
# Function to update Cache for given file. It stores the information about file
function UpdateCache() {
file=$1
path=`pwd`
date=`date +%s`
cat >>$cache<<EOF
 $1: $path:$date
EOF

}
#----------------------------------------------------------------------------#
# Function to get details from $rbinrc
function Read_rbinrc() {
if [[ ( -f "$rbinrc" ) ]]; then
switch=`grep "AUTO_CLEAN" $rbinrc|cut -d "=" -f2`
expiry=`grep "EXPIRY_DAYS" $rbinrc|cut -d "=" -f2`
else
 touch $rbinrc
 cat >>$rbinrc<<EOF
 AUTO_CLEAN=OFF
 EXPIRY_DAYS=30
EOF
switch="OFF"
fi
#echo "SWITCH: $switch"
#echo "EXPIRY: $expiry"
}
#----------------------------------------------------------------------------#
#function to set Autoclean option
function set_Autoclean() {
Read_rbinrc
 if [[ "$switch" == "OFF" ]];then
#---> when off
echo "$bold Autoclean status is $ylw OFF.$rst"
echo ""
read -p "$bold$ylw Activate Autoclean [$rst$bold ON/OFF$ylw] :$rst" option
   if [[ "$option" == "ON" ]];then
     switch="ON"
     Set_Crontab
   else
     switch="OFF"
  echo "$bold$red rbin$rst$bold: --->$grn Autoclean feature is remains deactivated.$rst"
   exit
   fi
read -p "$bold$ylw Set Expiry Days for Auto Deletion [$rst$bold$red in Days$rst$bold] :$rst" ndays
   if [[ "$ndays" != "" ]];then

cat >$rbinrc<<EOF
 AUTO_CLEAN=$switch
 EXPIRY_DAYS=$ndays
EOF
else
     ndays=30
cat >$rbinrc<<EOF
 AUTO_CLEAN=$switch
 EXPIRY_DAYS=$ndays
EOF
   fi
  echo "$bold$red rbin$rst$bold: --->$grn Autoclean feature is activated.$rst"
#<---when off
else
#---> when on
echo "$bold Autoclean status is $ylw ON.$rst"
echo ""
read -p "$bold$ylw Deactivate Autoclean [$rst$bold ON/OFF$ylw] :$rst" option
   if [[ "$option" == "OFF" ]];then
     switch="OFF"
     Remove_Crontab
   else
     switch="ON"
  echo "$bold$red rbin$rst$bold: --->$grn Autoclean feature is remains activated.$rst"
  exit
   fi

cat >$rbinrc<<EOF
 AUTO_CLEAN=$switch
 EXPIRY_DAYS=$ndays
EOF
 echo "$bold$red rbin$rst$bold: --->$grn Autoclean feature is deactivated.$rst"
#<--- When on
fi
}
#----------------------------------------------------------------------------#
# This function needs to be removed
#function to set Autoclean option
function set_Autoclean_2() {
echo " Setting Autoclean Option:"
echo ""
     switch=$1
#if ON,set crontab
     ndays=$2
#
 echo " AUTO_CLEAN=$switch"
 echo " EXPIRY_DAYS=$ndays"
#
cat >$rbinrc<<EOF
 AUTO_CLEAN=$switch
 EXPIRY_DAYS=$ndays
EOF
}
#----------------------------------------------------------------------------#
#function to set crontab
function Set_Crontab() {
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
echo "0 0 * * * rbin --autoclean" >> mycron
#install new cron file
crontab mycron
rm mycron
}
#----------------------------------------------------------------------------#
# Function to remove crontab
function Remove_Crontab() {
crontab -l > mycron
#echo new cron into cron file
a=`grep "rbin --autoclean" mycron`
if [ "$?" == "0" ];then
sed -i "/rbin --autoclean/d" mycron
#install new cron file
crontab mycron
rm mycron
fi
}
#----------------------------------------------------------------------------#
#function to Inspect files in $bin
function Inspect() {
 Read_rbinrc
 if [[ "$switch" == "ON" ]];then
    list=`ls $bin`
    #echo $list
    for file in $list;do
       del_date=`grep " $file:" $cache|cut -d ":" -f 3`
       cur_date=`date +%s`
       days=$(((cur_date - del_date)/86400))
       if [ $days -ge $expiry ];then
          rm -rf $bin/$file   
       fi
    done
 fi
now=`date`
echo "rbin:---> $now inspcted." >>$HOME/rbin.log
}
#----------------------------------------------------------------------------#
#function to Print the contents in $bin with Age
function listContents() {
 Read_rbinrc

   current_dir=`pwd`
if [[ "$current_dir" == "$bin" ]];then
  list=`ls $bin`
   for file in $list;do
   del_date=`grep " $file:" $cache|cut -d ":" -f 3`
   cur_date=`date +%s`
#
#--->
   days=$(((cur_date - del_date)/86400))
   hrs=$(((cur_date - del_date)/3600))
   mnts=$(((cur_date - del_date)/60))
   sec=$((cur_date - del_date))
#<---
totallefthrs=$((expiry*24 - hrs))
leftdays=$((totallefthrs/24))
lefthrs=$((totallefthrs%24))
#--->
if [[ "$switch" == "ON" ]];then
    echo "$bold[$red Delete in$rst$grn $leftdays $rst$red Days$rst$grn $lefthrs $rst$red Hrs $rst$bold]$rst $file"
else

   if [[ "$days" < "1" ]];then
      if [[ "$hrs" < "1" ]];then
         if [[ "$switch" == "ON" ]];then
           echo "$bold[$red $mnts Min $rst$bold] $file $rst"
         else
           echo "$bold[$red $mnts Min $rst$bold] $file $rst"
         fi
      else
         echo "$bold[$red $hrs Hrs $rst$bold] $file $rst"
      fi
   else
         echo "$bold[$red $days Days $rst$bold] $file $rst"
   fi
fi
   done
#<---
 else
    echo "$bold$red rbin$rst$bold: --->$ylw The current direcory is NOT a Recyclebin.$rst"
 fi
}
#----------------------------------------------------------------------------#
function print_help() {
cat <<EOF
-----------------------------------------------------------------------------
    <========================== RBIN =============================>
                 A command-line Recyclebin for Linux	            	     
-----------------------------------------------------------------------------

 Authour: Anji Babu Kapakayala
          IIT Kanpur, India.

 Laungauge: Shell/Bash

 Description: 
	
    RBIN is a software which acts as a RECYCLEBIN" to delete and restore the 
    files in Linux. Restores the selected file/directory to its original location.
    And deletes the files perminantly whose deletion date is more than 30 days.  

 Features:
    
    rbin                 ---> main excutable and deletes given files
    rbin -d/--del        ---> Deletes the files or Directories
    rbin -r/--restore    ---> Restores the given files.
    rbin -e/--emptybin   ---> Will empty the recyclebin
    rbin --SetAutoclean  ---> Options: on , off, Period_of_days to clean the bin
    rbin -h/--help       ---> Prints the information about rbin.
    rbin -f/--force      ---> Deletes the given file perminantly
    rbin -l/--list       ---> Lists the contents in Recyclebin along with 
                              the age from the day of deletion.


 Directories:
       
    recyclebin          ---> Place to store the deleted files
    recyclebin/.cache   ---> Contains the information about deleted files 
				(date of deletion & original location)

 Examples:

    rbin *              ---> Deletes all files from current directory.
    rbin -r *           ---> Restores all files from recyclebin.
    rbin -f *           ---> Removes all files perminantly from current directory.
    rbin file1          ---> Deletes the file1
    rbin -r file1       ---> Restore the file1
    rbin -e             ---> Makes recyclebin empty.
    rbin -s             ---> Allows to ON or OFF Auto clean feature.
    rbin anji_*         ---> Deletes all files starts with anji_
    rbin file1 file2 dir1 ---> Deletes file1 file2 dir1 
    rbin file_[1-3]*    ---> Deletes starts with file_1* file_2* file_3*
    
    rbin works perfectly with wildcards like *, [1-5], String*, etc. 
 
 Report bugs:    anjibabu480@gmail.com

 Cheers!
 Anji Babu
-----------------------------------------------------------------------------
EOF
}

#----------------------------------------------------------------------------#
function perform_task() {
if [[ "$1" != "" ]];then
#---> $2 open
  if [[ "$2" != "" ]];then
    
     case "$1" in
        -h|--help) print_help;;
        -d|--del|--delete)
         delete $2 ;;
        -e|--empty|--emptybin)
         EmptyBin ;;
        -r|--restore|--res)
         Restore $2;;
        -f|--force)
         Remove_Perminant $2;;
        *)
         delete $2
         ;;
     esac
   else
     case "$1" in
        -l|--list)listContents;;
        -h|--help) print_help;;
        -e|--empty|--emptybin)EmptyBin ;;
        --SetAutoclean|--SAC|-s)
          set_Autoclean;;
        -d|--del|--delete)
          if [[ "$narg" -lt "2" ]];then
             echo "$bold$red rbin$rst$bold: --->$ylw Expected Argument with -d tag.$rst"
          fi
          ;;
        -r|--restore|--res)
          if [[ $narg -lt 2 ]];then
             echo "$bold$red rbin$rst$bold: --->$ylw Expected Argument with -r tag.$rst"
          fi
          ;;
        -f|--force)
          if [[ "$narg" -lt "2" ]];then
             echo "$bold$red rbin$rst$bold: --->$ylw Expected Argument with -f tag.$rst"
          fi
          ;;
        --autoclean|--inspect|-ac)
          Inspect;;
        *) delete $1 ;;
     esac
   fi
#<--- $2 close
else
     echo "$bold$red rbin$rst$bold: Argument expected.!$rst"
     echo "$bold See $grn  rbin --help $rst"
fi
}
#----------------------------------------------------------------------------#
#    <========================== MAIN CODE =============================>
#----------------------------------------------------------------------------#
narg=$#
arg=$*

#echo "$narg"
#echo "$arg"

if [[ "$1" != "" ]];then
#---> Arg
  if [[ "$narg" != "1" ]];then
     for i in $arg;do
        if [[ "$i" != "$1" ]];then
#           echo "$i"
           perform_task $1 $i
        else
           perform_task $1 
        fi
     done
  else
     perform_task $1 
  fi
#<--- Arg
else
     echo "$bold$red rbin$rst$bold: Argument expected.!$rst"
     echo "$bold See $grn  rbin --help $rst"
fi

#----------------------------------------------------------------------------#
#          <============ ANJI BABU KAPAKAYALA ============>
#----------------------------------------------------------------------------#
