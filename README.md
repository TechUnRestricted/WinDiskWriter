<h1>WinDiskWriter</h1>

<p align="center">
  <img src="https://i.postimg.cc/0x7VXSz9/Artboard.png"/>
</p>

<p align="center">
  <a href="https://github.com/TechUnRestricted/windiskwriter/blob/main/license.md">
    <img alt="License" src="https://img.shields.io/github/license/TechUnReStricted/windiskwriter">
  </a>

  <a href="https://github.com/TechUnRestricted/windiskwriter/releases">
    <img alt="Releases" src="https://img.shields.io/github/downloads/TechUnRestricted/windiskwriter/total">
  </a>
  
  <a href="https://github.com/TechUnRestricted/windiskwriter/releases">
    <img alt="GitHub release (with filter)" src="https://img.shields.io/github/v/release/TechUnRestricted/windiskwriter">
  </a>

  <a href="#">
    <img alt="Code Size in Bytes" src="https://img.shields.io/github/languages/code-size/TechUnRestricted/windiskwriter">
  </a>

  <a href="https://github.com/TechUnRestricted/windiskwriter/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/TechUnRestricted/windiskwriter">
  </a>
</p>

<p>
  &emsp;&emsp;<b>WinDiskWriter</b> — an application for macOS that gives you the power to <b>create bootable USB drives with Microsoft Windows on your Mac</b>.<br>
  &emsp;&emsp;With this software, you have the flexibility and convenience to <b>prepare a flash drive with the Windows version of your choice</b>, whether you need to install Windows on another computer, run Windows on your Intel Mac, or test Windows on a virtual machine.<br><br>
&emsp;&emsp;<b>WinDiskWriter</b> offers a user-friendly graphical interface that simplifies the process and guides you through the steps.<br><br>
&emsp;&emsp;As <b>WinDiskWriter</b> is <i>still under development</i>, there may be some bugs or errors that need to be fixed. If you experience any issues or have any questions, please do not hesitate to <a href="https://github.com/TechUnRestricted/windiskwriter/issues">create an Issue</a> on GitHub and I will assist you as soon as possible.<br>
</p>

<center>
  <img alt="WinDiskWriter Main Window" src="https://i.postimg.cc/CFYbxwkD/Win-Disk-Writer-Main-Wind-w.png">
</center>

<pre>
 ⭐️ If you appreciate its functionality and want to support its development, you can <b><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">make a donation</a></b> ⭐️
</pre>

<h2>Table of Contents</h2>
<b>
<ol>
  <li><a href="#features">Feautures</a></li>
  <li><a href="#compatibility">Compatibility</a>
    <ol>
      <li><a href="#-macos-support">🍏 macOS Support</a></li>
      <li><a href="#-windows-images">💻 Windows Images</a></li>
    </ol>
  </li>
  <li><a href="#planned-features">Planned Features</a></li>
  <li><a href="#additional-information">Additional Information</a></li>
  <li><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">❤️ Support Me ❤️ (Donations)</a></li>
  <li><a href="#authors">Authors</a></li>
  <li><a href="#used-libraries">Used Libraries</a></li>
</ol>
</b>

<h2>Features</h2>
<ul>
  <li>
    📀 <b>Creating bootable USB drive with Windows Vista through 11 (incl. Server Editions)</b><br>
    <sub>WinDiskWriter automatically use the required writing logic for each Windows Image type.</sub>
  </li>
  <br>
  <li>
    🛠 <b>Patching Windows 11 Installer</b><br>
    <sub>You can bypass the hardware requirements for Windows 11, such as the <b>TPM chip</b> and <b>Secure Boot</b>, by patching the installer with <b>WinDiskWriter</b>.<br>
      This way, you can install Windows 11 on any EFI-capable x64 device, even if it does not meet the official specifications.</sub>
  </li>
  <br>
  <li>
    🔐 <b>Extracting EFI-compatible bootloader</b><br>
        <sub>You can create a EFI bootable USB drive for <b>Windows Vista</b> or <b>7</b> by <b>extracting the bootloader</b> from the installation file with <b>WinDiskWriter</b>.<br>
        This feature is useful if you want to install <b>Windows Vista</b> or <b>7</b> on a modern device that supports <b>EFI booting</b>.</sub>
  </li>
  <br>
  <li>
    🗂 <b>Splitting install.wim file</b><br>
        <sub>You can <b>split</b> a large <b>install.wim</b> file into <b>multiple .swm files</b> to fit the <b>FAT32</b> file size limit with <b>WinDiskWriter</b>.<br>
          This feature is necessary if you want to use a <b>FAT32 formatted USB drive</b>, which is more compatible with different devices and operating systems than <b>exFAT / NTFS</b></sub>
  </li>
</ul>

<h2>Compatibility</h2>
<h3>🍏 macOS Support</h3>
<table>
    <thead>
        <tr>
            <th>Version</th>
            <th>Architecture</th>
            <th>Is Verified</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Mac OS X Snow Leopard 10.6</td>
            <td rowspan="10" align="center">x86_64</td>
            <td rowspan="3" align="center">
              Not Yet<br>
              <sub>(should work)</sub>
            </td>
        </tr>
        <tr>
            <td>Mac OS X Lion 10.7</td>
        </tr>
        <tr>
            <td>Mac OS X Mountain Lion 10.8</td>
        </tr>
        <tr>
            <td>OS X Mavericks 10.9</td>
            <td rowspan="999" align="center">Yes</td>
        </tr>
        <tr>
            <td>OS X Yosemite 10.10</td>
        </tr>
        <tr>
            <td>OS X El Capitan 10.11</td>
        </tr>
        <tr>
            <td>macOS Sierra 10.12</td>
        </tr>
        <tr>
            <td>macOS High Sierra 10.13</td>
        </tr>
        <tr>
            <td>macOS Mojave 10.14</td>
        </tr>
        <tr>
            <td>macOS Catalina 10.15</td>
        </tr>
        <tr>
            <td>macOS Big Sur 11.0</td>
            <td rowspan="999" align="center">
              x86_64,<br>
              ARM64
            </td>
        </tr>
        <tr>
            <td>macOS Monterey 12.0</td>
        </tr>
        <tr>
            <td>macOS Ventura 13.0</td>
        </tr>
        <tr>
            <td>macOS Sonoma 14.0</td>
        </tr>
    </tbody>
</table>

<h3>💻 Windows Images</h3>
<table>
    <thead>
        <tr>
            <th>Version</th>
            <th>Architecture</th>
            <th>Boot Mode</th>
            <th>Is Verified</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Windows Vista</td>
            <td rowspan="999" align="center">x86_64</td>
            <td rowspan="999" align="center">UEFI</td>
            <td rowspan="999" align="center">Yes</td>
        </tr>
        <tr>
            <td>Windows 7</td>
        </tr>
        <tr>
            <td>Windows 8</td>
        </tr>
        <tr>
            <td>Windows 8.1</td>
        </tr>
        <tr>
            <td>Windows 10</td>
        </tr>
        <tr>
            <td>Windows 11</td>
        </tr>
    </tbody>
</table>

<h2>Planned Features</h2>
<ul>
  <li>
    🚀 <b>Legacy BIOS booting option</b><br>
    <sub>You will be able to create bootable USB drives for Windows that can boot in <b>Legacy BIOS mode</b>, which is an older and simpler way of booting than UEFI.<br>
      This feature will be useful if you want to <b>install Windows on a device that does not support UEFI</b> or has compatibility issues with it.
    </sub>
  </li>
  <br>
  <li>
    📁 <b>Individual partitions selection in WinDiskWriter</b><br>
    <sub>You will be able to <b>choose which partitions you want to write to your USB drive</b> from the <b>WinDiskWriter</b> graphical interface, instead of writing the whole disk image.<br>
      This feature will give you more control and flexibility over the content and size of your USB drive.</sub>
  </li>
  <br>
  <li>
    🔍 <b>Toggle to show internal drives</b><br>
        <sub>You will be able to see and select your <b>internal drives</b> as well as your external drives in <b>WinDiskWriter</b>, by using a <b>toggle switch</b>.<br>
          This feature will allow you to use <b>WinDiskWriter</b> with <b>any drive</b> connected to your Mac, but <b>you should be careful not to overwrite your important data</b>.</sub>
  </li>
  <br>
  <li>
    🗜 <b>Splitting install.esd (compressed system image) files for better FAT32 filesystem compatibility</b><br>
        <sub>You will be able to split a large install.esd file into multiple .swm files to fit the FAT32 file size limit with <b>WinDiskWriter</b>.<br>
          This feature will be necessary if you want to use a <b>FAT32</b> formatted USB drive with a Windows image that has a <b>compressed system image file larger than 4GB</b>, which is common for some repacks.</sub><br>
    <sub><sup><b>!!!IMPORTANT NOTICE!!! Large <b>.wim</b> install images are supported. The wimlib library needs to be updated to a newer version in order to work with <b>compressed</b> .esd files.</b></sup></sub>
  </li>
  <br>
  <li>
    🎨 <b>UI Elements drawing issues resolution on Mac OS X Mavericks 10.9 and lower</b><br>
        <sub>You will be able to enjoy a <b>smooth</b> and <b>consistent user interface</b> on <b>older versions of macOS</b>, such as Mavericks 10.9 and lower, by <b>fixing the UI</b> elements <b>drawing issues</b> that affect them.<br>
          This feature will improve the <b>appearance</b> and <b>usability</b> of <b>WinDiskWriter</b> on <b>legacy systems</b>.</sub>
  </li>
  <br>
  <li>
    💻 <b>32-Bit CPU support for the existing fat binary (x86_64 + ARM64 + x86)</b><br>
        <sub>You will be able to run <b>WinDiskWriter on 32-Bit Macs</b> by adding <b>x86 support</b> to the existing fat binary that already supports x86_64 and ARM64 architectures.<br>
          This feature will extend the <b>compatibility</b> and <b>accessibility</b> of <b>WinDiskWriter</b> to <b>older Mac models that have 32-Bit CPUs</b>.</sub><br>
    <sub><sup><b>Currently, can't build an x86-32 binary by myself since I'm using an ARM64e Mac.</b></sup></sub>
  </li>
  <br>
  <li>
    📝 <b>Option to add ei.cfg to enable edition selection</b><br>
        <sub>You will be able to add an <b>ei.cfg</b> file to your USB drive with <b>WinDiskWriter</b>, which will allow you to <b>choose the Windows edition you want to install</b>, regardless of the serial number of the hardware.<br>
          This feature will be helpful if you want to <br>install Windows Pro on a device that came with Windows Home, or vice versa</sub>.</sub>
  </li>
  <br>
  <li>
    🌐 <b>Option to remove the online account requirement from Windows 11 22H2+</b><br>
        <sub>You will be able to <b>remove the mandatory requirement for a Microsoft account</b> on <b>Windows 11 22H2+</b> with <b>WinDiskWriter</b>, which will let you <b>create a local account</b> instead.<br>
          This feature will give you <b>more privacy</b> and <b>control</b> over your <b>Windows 11</b> installation.</sub>
  </li>
</ul>

<h2>Additional Information</h2>
<p>
&emsp;&emsp;<b>WinDiskWriter</b> is written in <b>Objective-C</b>, a programming language that ensures <b>high compatibility with older versions of macOS</b>. Objective-C is an extension of the C language that adds object-oriented features and dynamic runtime. Objective-C was the primary language for developing applications for macOS and iOS until Swift was introduced in 2014.<br>
&emsp;&emsp;You can run <b>WinDiskWriter</b> as a self-contained binary that <b>does not require any external dynamic libraries</b>, making it <b>reliable</b> and <b>portable</b>. A binary file is an executable file that contains machine code that can be directly run by the computer. A self-contained binary file includes all the code and resources that are needed for the program to function, without depending on any other files or libraries.<br>
&emsp;&emsp;Despite supporting multiple architectures (<b>x86_64</b> and <b>ARM64</b>), <b>WinDiskWriter</b> has a <b>small application size</b>, thanks to the <b>efficiency of Objective-C</b>, which is <b>supported by all versions of Mac OS X</b>.
</p>

<h2>❤️ Support Me ❤️ (Donations)</h2>
<ul>
  <li>
    Bitcoin (BTC): <b>bc1qe2z68uwgplxfzspdy5pnxhzza2spep0ryk5zeq</b>
  </li>
  <li>
    Toncoin [TON]: <b>UQBzFgALzKsCW6dLrc4sA0WoBhdODEK2KliGgoi1Hj8UqXOb</b>
  </li>
  <li>
    Etherium (ETH): <b>0x1410acAc3e0De885f4fb8C305a2F7B586d47c5ff</b>
  </li>
  <li>
    BNB Beacon Chain (BNB): <b>bnb1h2svmvj9842xk49qjflza4q8yqn2kd9dsxp9h9</b>
  </li>
  <li>
    Tether USD [USDT] (<b>E</b>RC20): <b>0x1410acAc3e0De885f4fb8C305a2F7B586d47c5ff</b>
  </li>
  <li>
    Tether USD [USDT] (<b>T</b>RC20): <b>TKR1dtAHsHwaQYwUx6FGTwpfUM9rzepGVu</b>
  </li>
</ul>

<h2>Authors</h2>
<ul>
    <li>
        <a href="https://www.github.com/TechUnRestricted">@TechUnRestricted</a>
    </li>
</ul>

<h2>Used Libraries</h2>
<ul>
    <li>
      <a href="https://wimlib.net/">wimlib</a> <sub><sup><a href="https://github.com/TechUnRestricted/windiskwriter/blob/main/libs/wimlib/License.txt">(GNU LESSER GENERAL PUBLIC LICENSE Version 3)</a></sup></sub>
    </li>
</ul>

