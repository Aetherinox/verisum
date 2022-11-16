# VeriSum

A Windows utility created in order to generate a hash digest with checksums for files or folders. Generated checksums can then be signed using your specified GPG key into an armored `asc` format.

Users who download your project will then be able to download and verify that your project came from the authentic developer by using the digest to compare the checksums between their current downloaded files, and the files officially belonging to the project.

## Structure

```
📁 .docs                    info related to this library
📁 .lib                     required library files -- do not modify
📁 .logs                    logs the results when comparing project files against SHA txt in "checksums" folder
📁 checksums                generated and gpg signed checksums for project stored here
📁 project                  Your project's root folder should be placed in here
   📁 Your Project Folder
```

## Files

```
📄 VeriSum_Generate.bat     Generates a new checksum digest by reading all files in "project" folder.
                                    New checksum txt will be stored in "checksums" folder.
📄 VeriSum_Sign.bat         Takes a generated checksum digest and signs it with a specified GPG key.
📄 VeriSum_Verify.bat       Compares the generated checksum txt in "checksums" with files in "project"
```

## Generating

To generate a brand new hash digest with your project's checksum, place your project's root folder inside the `project` folder. Then open `VeriSum_Generate.bat` wait while your digest is created. Once the hash digest file is generated; it will be placed in the `checksums` folder.

You have the option to generate a checksum for every file in the project, or you can generate a single checksum for the entire project.

Generating a new digest supports the following algorithms:

- MD5
- SHA1
- SHA256
- SHA384
- SHA512

`SHA256` is the default algorithm.
To change rhe algorithm used; open each BAT file and modify:

```bash
SET algo=SHA256
```

![generate](https://i.imgur.com/PqVca4g.png)

Once you have generated a hash digest; it will appear in the following structure in `\checksums\*.txt`. The filename is dependent on which algorithm you choose.

```gpg
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

5c1211559dda10592cfedd57681f18f4a702410816d36eda95aee6c74e3c6a47  .lib/cecho.exe
ef52afdf2356a5e2e42e1b117a5cffb4663b4cc434de09db62e7310496ba20c0  .lib/dos2unix.exe
899482064f3ebb2dd8a9d368b7e51680f0e704cd9ffe188f187faadc0c05faa4  .lib/sha256sum.exe
86a08d6e148759f5b5637af247da5ba2cf779f141af891a9d7b5f6dca06df126  .lib/verisum.exe
7b3759a83aa3905885fa167b7c43192f33d0e8bba81c25af20ac839cd2e750e6  VeriSum_Generate.bat
5b92a39fa80e44fa0a98534fea03a8009916472fb5e37d6f69aa22f93c4311a8  VeriSum_Sign.bat
fa1b7c8a835652e9598682feed205d1546f2796947f1c2b649082dc29c277732  VeriSum_Verify.bat
```

### Ignored files

By default; VeriSum ignores generating a checksum for the following files:

- \*gitignore
- \*.md
- \*docs

Open the `.bat` files if you wish to edit these exclusions. The character `*` can be used as a wildcard.

## Signing

This utility will take your hash digest file populated with your project's checksums, and verify all the generated checksums between the digest file and project files themselves. After all checksums are verified; an armored `asc` gpg key is generated with your gpg signature. If your gpg key has a passphrase; you will be prompted to supply it for the signing to be complete. The final digest with your armored `asc` checksums will be placed in the `checksums` folder, along with your original digest txt. That asc file can then be uploaded to places like Github when you publish releases for your project.

![sign](https://i.imgur.com/xPfLJ1Z.png)

### GPG Key - Automatic

To specify your GPG key, open `VeriSum_Sign.bat` in a text editor.

Locate and edit:

```git
SET gpg_keyid=XXXXXXXX
```

After providing your GPG key, re-launch the utility and it will automatically sign the provided hash digest.

### GPG Key - Manual

The `VeriSum_Sign.bat` utility also includes the ability to provide your GPG key on the fly as you are signing a hash digest.

![sign](https://i.imgur.com/AyDh6mS.png)

If you execute the sign utility without configuring your GPG key; you will be prompted with instructions on how to add your GPG key. You will then be asked to provide a GPG key for a `one-time` signature. If you do not provide the correct key, or leave it blank; the application will close.

## Verify

To verify a digest's checksums against your actual project files, open `VeriSum_Verify.bat`. The script will automatically grab your generated digest txt file from the `checksums` folder, and compare that with the files in the `project` folder. It will return the results of that check, which will either be successful, or it will list the files that failed the checksum verification. On top of this information being shown in console; a log file will be pushed to the `.logs` folder.

![verify](https://i.imgur.com/MwH8zCB.png)

### SHA256SUM.EXE

`.lib\sha256sum.exe` has been provided in this utility as an alternative tool. It is `not` required for VeriSum to function. It is only there in case people wish to utilize it.

In order to use this file, your projects's hash digest txt file and your project's root folder must be placed together in the same folder with sha256sum.exe.

Refer to the following example:

```
📁 .docs
📁 .lib
📁 .logs
📁 checksums
📁 project
📄 SHA256.txt
➡️ sha256sum.exe
```

You can open `Command Prompt`, `Terminal`, or `Powershell`, navigate to the folder with all of the files listed above, and execute the command:

```shell
sha256sum -c YourSHAFile.txt
```

## Linux

VeriSum ensures that all generated hash digests are Linux compatible. VeriSum converts a created text file from `CRLF` (Carriage Return and Line Feed -- Windows) to `LF` (Line Feed -- OSX / Linux). This allows you to utilize the same hash digest in Linux to do comparisons there.

Place the generated hash digest `.txt` file on your Linux computer. Then move your project files into a folder.
Once you have these all transferred; open `Terminal`, change to the directory with your project files, and execute the command:

```shell
sha256sum --check /path/to/sha256.txt
```

You will see something similar to:

```shell
> sha256sum --check digest/sha256.txt

.lib/cecho.exe:         OK
.lib/dos2unix.exe:      OK
.lib/sha256sum.exe:     OK
.lib/verisum.exe:       OK
VeriSum_Generate.bat:   OK
VeriSum_Sign.bat:       OK
VeriSum_Verify.bat:     OK
```

To get a full list of commands available; view the following:

- [MD5](https://man7.org/linux/man-pages/man1/md5sum.1.html "MD5")
- [SHA1](https://man7.org/linux/man-pages/man1/sha1sum.1.html "SHA1")
- [SHA256](https://man7.org/linux/man-pages/man1/sha256sum.1.html "SHA256")
- [SHA384](https://man7.org/linux/man-pages/man1/sha384sum.1.html "SHA384")
- [SHA512](https://man7.org/linux/man-pages/man1/sha512sum.1.html "SHA512")

## Libraries

### [cecho](https://www.codeproject.com/Articles/17033/Add-Colors-to-Batch-Files "cecho")

Special thanks to Thomas Polaert; the developer of `cecho`. This library makes batch files much more palatable in terms of getting important information across to the user.

### [sha256sum](https://g10code.com/ "sha256sum")

This library is developed by [g10code](https://g10code.com/ "g10code")