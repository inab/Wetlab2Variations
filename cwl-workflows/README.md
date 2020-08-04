# Rare Disease workflow
This implementation was done for the ELIXIR EXCELERATE Demonstrator to be run on WES-TES environment.

The main CWL file is workflow.cwl

The pdf file is a longer explanation of the Demonstrator.

There is also task related to input file transfer (curl) and the output file transfer to a private FTP server. 
The needed URLs and FTP credential are given as input parameters. 

The input files are assumed to come from a web server. Idea there is to make some configurations more modular and 
some tools like lftp or curl have easier to write script parameter files instead of command line parameters. 

For the output file transfer was installed pureftpd server. It allows to create virtua user account and to execute an upload script (man pure-uploadscript).
Thus, it possible to move files automatically to else where that with ftp credential cannot be used to download the files later.
Another user account can be used then to access the files.

The .yml files allow to run each cwl files separately with cwltool. 
There you need to have in the input files in defined in path.
Using local files allow faster execution of the pipeline or execution of just a simple task. 
