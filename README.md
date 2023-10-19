# Verisum

A Windows utility created in order to generate a hash digest with checksums for files or folders. Generated checksums can then be signed using your specified GPG key into an armored `asc` format.

Users who download your project will then be able to download and verify that your project came from the authentic developer by using the digest to compare the checksums between their current downloaded files, and the files officially belonging to the project.

## Structure

```
📁 .docs                    info related to this library
📁 .lib                     required library files -- do not modify
📁 .logs                    outputs the results of verifications against SHA in "checksums" folder
📁 checksums                generated and gpg signed checksums for project stored here
📁 project                  Your project's root folder should be placed in here
   📁 Your Project Folder
```

<br />

---

<br />

## Files

| File | Description |
| --- | --- |
| 📄 Verisum_Generate.bat | Generates a new checksum digest by reading all files in "project" folder. <br /> Generated checksums are stored in `checksums` folder. |
| 📄 Verisum_Sign.bat | Takes a generated checksum digest and signs it with a specified GPG key. |
| 📄 Verisum_Verify.bat | Compares the generated checksum txt in "checksums" with files in "project" |


<br />

---

<br />

## Generating

To generate a brand new hash digest for your project, place your project's root folder inside the `project` folder. Then open `Verisum_Generate.bat` and wait while your digest is created. Once done; it will be placed in the `checksums` folder.

You have the option to generate a checksum for every file in the project, or you can generate a single checksum for the entire project.

![4cUmHnB](https://github.com/Aetherinox/Verisum/assets/118329232/4f187123-5610-4d9c-8cb5-190f37227643)

### Single Checksum
A single checksum will be generated based on the overall project.

<br />

### Per File Checksum
Each file in your project will have its very own checksum created.

<br />

### Algorithms

Generating a new digest supports the following algorithms:

- MD5
- SHA1
- SHA256
- SHA384
- SHA512

<br />

`SHA256` is the default algorithm.
To change the algorithm used; open the `config.ini` file and modify:

```ini
algo=SHA256
```

<br />

Once you have generated a hash digest; it will appear in the following structure in `\checksums\*.txt`. The filename is dependent on which algorithm you choose.

```gpg
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

5c1211559dda10592cfedd57681f18f4a702410816d36eda95aee6c74e3c6a47  .lib/cecho.exe
ef52afdf2356a5e2e42e1b117a5cffb4663b4cc434de09db62e7310496ba20c0  .lib/dos2unix.exe
899482064f3ebb2dd8a9d368b7e51680f0e704cd9ffe188f187faadc0c05faa4  .lib/sha256sum.exe
86a08d6e148759f5b5637af247da5ba2cf779f141af891a9d7b5f6dca06df126  .lib/verisum.exe
7b3759a83aa3905885fa167b7c43192f33d0e8bba81c25af20ac839cd2e750e6  Verisum_Generate.bat
5b92a39fa80e44fa0a98534fea03a8009916472fb5e37d6f69aa22f93c4311a8  Verisum_Sign.bat
fa1b7c8a835652e9598682feed205d1546f2796947f1c2b649082dc29c277732  Verisum_Verify.bat
```

### Ignored files

By default; Verisum ignores generating a checksum for the following files:

- \*.gitignore
- \*.md
- \*docs

Open the `.bat` files if you wish to edit these exclusions. The character `*` can be used as a wildcard.

<br />

---

<br />

## Signing

This utility will take your hash digest file populated with your project's checksums, and verify all the generated checksums between the digest file and project files themselves. After all checksums are verified; an armored `asc` gpg key is generated with your gpg signature. If your gpg key has a passphrase; you will be prompted to supply it for the signing to be complete. The final digest with your armored `asc` checksums will be placed in the `checksums` folder, along with your original digest txt. That asc file can then be uploaded to places like Github when you publish releases for your project.

Verisum provides you with two ways to supply a GPG key.
1. Adding your GPG key via the `config.ini` file [Automatic]
2. Entering your GPG key when you launch the `Verisum - Sign.bat` file. [Manual]

<br />




<br />

### GPG Key - Automatic

To specify your GPG key, open `Verisum_Sign.bat` in a text editor.

Locate and edit:

```git
SET gpg_keyid=XXXXXXXX
```

After providing your GPG key, re-launch the utility and it will automatically sign the provided hash digest.

<br />

### GPG Key - Manual

The `Verisum_Sign.bat` utility also includes the ability to provide your GPG key on the fly.

![XYUWvBO](https://github.com/Aetherinox/Verisum/assets/118329232/cbf9d422-d81a-4ae6-84f8-ef1bd7db67b4)

If you execute the sign utility without configuring your GPG key; you will be prompted with instructions on how to add your GPG key. You will then be asked to provide a GPG key for a `one-time` signature. If you do not provide the correct key, or leave it blank; the application will close if you have not included your GPG key within the `config.ini`.

<br />

---

<br />

## Verify

To verify a digest's checksums against your actual project files, open `Verisum_Verify.bat`. The script will automatically grab your generated digest txt file from the `checksums` folder, and compare that with the files in the `project` folder. It will return the results of that check, which will either be successful, or it will list the files that failed the checksum verification. On top of this information being shown in console; a log file will be pushed to the `.logs` folder.

![Lzxujmd](https://github.com/Aetherinox/Verisum/assets/118329232/d4fc17fc-f813-48fd-ab46-e81a05d8fc64)

<br />

### SHA256SUM.EXE

`.lib\sha256sum.exe` has been provided in this utility as an alternative tool. It is `not` required for Verisum to function. It is only there in case people wish to utilize it.

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

<br />

---

<br />

## Linux

Verisum ensures that all generated hash digests are Linux compatible. Verisum converts a created text file from `CRLF` (Carriage Return and Line Feed -- Windows) to `LF` (Line Feed -- OSX / Linux). This allows you to utilize the same hash digest in Linux to do comparisons there.

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
Verisum_Generate.bat:   OK
Verisum_Sign.bat:       OK
Verisum_Verify.bat:     OK
```

To get a full list of commands available; view the following:

- [MD5](https://man7.org/linux/man-pages/man1/md5sum.1.html "MD5")
- [SHA1](https://man7.org/linux/man-pages/man1/sha1sum.1.html "SHA1")
- [SHA256](https://man7.org/linux/man-pages/man1/sha256sum.1.html "SHA256")
- [SHA384](https://man7.org/linux/man-pages/man1/sha384sum.1.html "SHA384")
- [SHA512](https://man7.org/linux/man-pages/man1/sha512sum.1.html "SHA512")

<br />

---

<br />

## Libraries

### [cecho](https://www.codeproject.com/Articles/17033/Add-Colors-to-Batch-Files "cecho")

Special thanks to Thomas Polaert; the developer of `cecho`. This library makes batch files much more palatable in terms of getting important information across to the user.

### [sha256sum](https://g10code.com/ "sha256sum")

This library is developed by [g10code](https://g10code.com/ "g10code")