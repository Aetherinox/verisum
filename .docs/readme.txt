

VeriSum_Generate_.bat       Generates hash digest file (ex: SHA256.txt)
                            Place project inside "project" folder
                            You can then either drag "project" folder over top of VeriSum_Generate_.bat.
                                Or you can just click on VeriSum_Generate.bat.
                                The script supports both methods.
                            New SHA256.txt will be placed in "checksums" folder.


VeriSum_Sign.bat            Verifies and signs a hash digest with your GPG key.
                            Supports dragging hash digest file onto VeriSum_Sign.bat
                                Or you can place SHA256.txt inside 'checksums' folder
                                and then click on VeriSum_Sign.bat.
                                The script supports both.

                            Will generate SHA256.sig AND SHA256.sig.asc in 'checksums' folder.

VeriSum_Verify.bat          Verifies hash digest txt checksums with actual files for project.
                            Automatically uses the digest file in 'checksums' folder.
                            If you have the algorithm set to SHA512, then the script will search for
                                checksums\SHA512.txt

.lib\sha256sum.exe          As an alternative to verifying checksums with VeriSum;
                            you can use sha256sum.exe located in the .lib folder.

                            In order to use this, you must have the hash digest txt file, and the
                            project root folder in the same directory with sha256sum.exe
                            Otherwise, all checksums will fail.