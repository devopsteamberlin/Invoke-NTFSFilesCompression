﻿
Function Invoke-NTFSFilesCompression {

  <#
  .SYNOPSIS
   Compress files with given extention older than given amount of time
  .DESCRIPTION
   The function is intended for compressing (using the NTFS compression) all files with particular extensions older than given time unit
  .EXAMPLE
   Compress files with extension log in folder c:\test that are older than 20 minutes
   Invoke-NTFSFilesCompression -Path C:\test -OlderThan 20
  .EXAMPLE
   Compress files with extension txt in folder c:\test that are older than 1 hour
   Invoke-NTFSFilesCompression -Path C:\test -OlderThan 1 -TimeUnit hours -Extension "txt"
  .PARAMETER Path
  The folder path that contain files. Folder path can be pipelined.
  .PARAMETER $OlderThan
   The count of units that are base to comparison file age.
  .PARAMETER TimeUnit
   The unit of time that are used to count. The default time unit are minutes.
  .PARAMETER Extension
   The extention of files that will be processed. The default file extenstion is "log".
  .NOTES
   AUTHOR: Wojciech Sciesinski, wojciech@sciesinski.net
   LICENSE: This code is licensed under GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007 http://www.gnu.org/licenses/gpl-3.0.txt
   KEYWORDS: NTFS, compression, PowerShell
   LASTEDIT: 2013-10-08
   VERSION HISTORY
   1.0.0 - 2013-10-04 - Initial edition
   1.0.1 - 2013-10-08 - Function renamed from Start-NTFSFilesCompression to Invoke-NTFSFilesCompression
   1.0.2 - 2013-10-08 - Information about licensing added, keywords extended 
  #>

  [CmdletBinding(
  SupportsShouldProcess=$true
  )]

 Param (

    [Parameter(mandatory=$true,ValueFromPipeline=$true)]
    [string[]]$Path,
    
    [Parameter(mandatory=$true)]
    [int]$OlderThan,

    [Parameter()]
    [string[]]
    [ValidateSet("minutes","hours","days","weeks")]
    $TimeUnit="minutes",

    [Parameter()]
    [string[]]$Extension="log"
       
)

    BEGIN {

        $excludedfiles = "temp.log","temp2.log","source.log"

        # translate action to numeric value required by the method
        switch ($TimeUnit) {
            "minutes" {
                $multiplier = 1
                break
            }
            "hours" {
                $multiplier = 60
                break
            }
            "days" {
                $multiplier = 1440
                break
            }
            "weeks" {
                $multiplier = 10080
                break
            }
        }

        $OlderThanMinutes = $($OlderThan * $multiplier)
                               
        $compressolder = $(get-date).AddMinutes(-$OlderThanMinutes)

        $filterstring = "*."+$Extension

        $files=Get-ChildItem -Path $path -Filter $filterstring
    
    } #END BEGIN

    PROCESS {

        ForEach ( $i in $files ) {

            if ( $i.Name -notin $excludedfiles ) {

                $filepathforquery = $($i.FullName).Replace("\" , "\\")

                $file = Get-WmiObject -Query "SELECT * FROM CIM_DataFile WHERE Name='$filepathforquery'"

                if ($file.compressed -eq $false -and $i.LastWriteTime -lt  $compressolder) {

                    Write-Verbose "Start compressing file $i.name"

                    #Invoke compression
                    $file.Compress() | out-null

                } #End if


            } #End if
   

        } #End loop

    } #End PROCESS


} #End Invoke-LogFilesCompression function