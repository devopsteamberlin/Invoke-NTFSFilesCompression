
Function Start-NTFSFilesCompression {

  <#
  .SYNOPSIS
   Compress files with given extention older than given amount of time
  .DESCRIPTION
   The function is intended for compressing (using the NTFS compression) all files with particular extensions older than given time unit
  .EXAMPLE
   Compress files with extension log in folder c:\test that are older than 20 minutes
   Start-NTFSFilesCompression -Path C:\test -OlderThan 20
  .EXAMPLE
   Compress files with extension txt in folder c:\test that are older than 1 hour
   Start-NTFSFilesCompression -Path C:\test -OlderThan 1 -TimeUnit hours -Extension "txt"
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
   LASTEDIT: 2013-10-04
   KEYWORDS: NTFS, compression
   VERSION HISTORY
   1.0 Initial edition

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


} #End Start-LogFilesCompression function