CoreData ORM util auto-generate
===============================

ORM can be a very subjective thing, so this will only suit a certain type of project / process!

CoreData can be very useful, and can get in the way. For different projects I've used direct SQLite access, CoreData, a mix of both, and then my own ORM mapping util classes. In the case of the latter, a lot of code was being repeated. Yes, you could argue that you shouldn't be using ORM mapping classes with CoreData, but then, I found, a lot more code was being repeated!

For mid-complexity projects, I found using CoreData helps (especially with new iOS devs on the team). I've also found using ORM mapping classes makes code a lot cleaner, and more useful.

If you've got this far, and agree, then this PERL script is what I use to auto-generate:
* Properties to include in an ORM mapping classe (.h and .m)
* Accessors (getters and setters) to set the ORM instance values from the CoreData ManagedObject instance, and vice versa.
* Code to populate the ORM instance from JSON (includes support for different names/naming schemes for ORM properties and JSON keys).
* Some constants for the CoreData property names (column / field names in the more traditional database sense) useful for including in a `consts.h` file, or equivalent.
* CoreData definitoin XML (suitable for pasting straight in to the CoreData source file, bypassing the UI. E.g. `Model.xcdatamodeld/Model.xcdatamodel/contents`).

Installation
------------
Just download the PERL script and run! The CPAN module `Term::ReadKey` is the most complicated dependency (and is available on most standard PERL installations anyway, including OS X).

Usage
-----
Run the PERL script without any arguments to see a brief explanation of the required arguments. Also look at the profile.tab file to see a sample of fields.

**Example**

	./ormgen.pl profile.tab Profile pro
This will generate a series of `out-*.txt`. Have a look to see the code produced. In the above example, `Profile` is the Class name for our ORM mapping class. `pro` is the instance name for a given instance of that mapping class.

The input is a standard tab-delimited file with three columns. The first column is the SQL field name / CoreData property name. The second column is the JSON key name. The third column is the type (**string**, **integer**, **date/time**, **boolean** and **double** are supported). Finally, when saving the file, make sure to maintain the tab-delimit (rather than the more standard comma-delimited/comma-separated CSV formta), and don't quote the text values (no &quot; around each text value).

Support / Contributing
----------------------
Use Git issues and pull requests (which are both welcome). If you are stuck on something related to the script (rather than generic iOS / CoreData coding help!) contact me [@cgarvey on Twitter](http://twitter.com/cgarvey).
