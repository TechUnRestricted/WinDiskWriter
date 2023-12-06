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

<pre>
  <p align="center">💖 Dear user, if you like my work, please <b><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">support me financially</a></b> 💖</p></pre>

<b>WinDiskWriter</b> — bootable disk creator for macOS.<br>
You can use this software to create a bootable universal USB drive that supports both **UEFI** and **Legacy BIOS** modes.<br>
With this USB drive, you can install and enjoy <strong>Microsoft Windows</strong> on your <strong>PC</strong>, <strong>Intel Mac</strong> or <strong>Virtual Machine</strong>.

This software has a <b>straightforward UI</b> that makes it easy to use and understand.<br>
You can simply select the <b>Windows image file</b>, the <b>destination device</b>, and the <b>options</b> you want, and then click the “Start” button to start the process.

<center>
  <img alt="WinDiskWriter Main Window" src="https://i.postimg.cc/CFYbxwkD/Win-Disk-Writer-Main-Wind-w.png">
</center>

<b>WinDiskWriter</b> will show you the progress and status of the operation, and notify you when it is done.<br>
UI is designed to be user-friendly and intuitive, so <strong>you can create bootable USB drives with Windows without any hassle</strong>.

<h2>Table of Contents</h2>
<b>
<ol>
  <li><a href="#features">Feautures</a></li>
  <li><a href="#compatibility">Compatibility</a>
    <ol>
      <li><a href="#-supported-windows-images-iso">💻 Supported Windows Images (.iso)</a></li>
      <li><a href="#-supported-macos-versions">🍏 Supported macOS Versions</a></li>
    </ol>
  </li>
  <li><a href="#planned-changes">Planned Changes</a></li>
  <li><a href="#additional-information">Additional Information</a></li>
  <li><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">❤️ Support Me ❤️ (Donations)</a></li>
  <li><a href="#authors">Authors</a></li>
  <li><a href="#used-external-software">Used External Software</a></li>
</ol>
</b>

<h2>Features</h2>
<ul>
   <li>
     📀 <strong>Create bootable USB disk drives Microsoft Windows starting from Windows Vista up to Windows 11</strong><br>
      <sub>
        WinDiskWriter automatically use the required writing logic for each Windows Image type.
      </sub>
   </li>
  <br>
   <li>
     🛠 <strong>Patch Windows 11 Installer</strong><br>
      <sub>
        You can bypass  TPM, Minimum RAM, Secure Boot and some other System Requirements set by Microsoft for Windows 11.<br>
        All you need is tick a checkbox «<strong>Bypass Installer Requirements</strong>» and WinDiskWriter will do the rest of the job for you.
      </sub>
   </li>
  <br>
   <li>
     👾 <strong>Legacy BIOS boot support</strong><br>
      <sub>
        You can create an all-in-one USB drive that supports both <strong>UEFI</strong> and <strong>Legacy</strong> boot modes.<br>
        It&#39;s required if you want to install the Microsoft Windows from the bootable media on computers with <strong>older firmwares</strong> that don&#39;t support modern <strong>EFI booting</strong>.
      </sub>
   </li>
  <br>
   <li>
     🔐 <strong>Prepare Windows Vista / Windows 7 images to boot in EFI mode</strong><br>
      <sub>
        Initially, these Microsoft Windows versions don&#39;t support EFI booting out-of-box.<br>
        An additional steps are required to make these images bootable, such as <strong>extracting a EFI-capable bootloader</strong> from the install.wim (.esd). WinDiskWriter performs this operation automatically.
      </sub>
   </li>
  <br>
   <li>
     🗂 <strong>Split Windows Installer Image</strong><br>
      <sub>
        Some .iso&#39;s contains a large (<strong>&gt;4GB</strong>) <strong>install.wim</strong> file.<br>
        Since our preferable filesystem is FAT32, we need to <strong>split this file into some parts</strong>.<br>
        This operation is handled by WinDiskWriter, so you don&#39;t need to participate in this process.
      </sub>
   </li>
</ul>

<h2>Compatibility</h2>
<h3>💻 Supported Windows Images (.iso)</h3>
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
            <td>Windows 11</td>
            <td align="center">x64</td>
            <td rowspan="6" align="center">UEFI,<br>Legacy</td>
            <td rowspan="6" align="center">Yes</td>
        </tr>
        <tr>
            <td>Windows 10</td>
            <td rowspan="5" align="center">x64,<br>x32</td>
        </tr>
        <tr>
            <td>Windows 8.1</td>
        </tr>
        <tr>
            <td>Windows 8</td>
        </tr>
        <tr>
            <td>Windows 7</td>
        </tr>
        <tr>
            <td>Windows Vista</td>
        </tr>
    </tbody>
</table>

<h3>🍏 Supported macOS Versions</h3>
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
            <td>macOS Sonoma 14.0</td>
            <td rowspan="4" align="center">x86_64,<br>ARM64</td>
            <td rowspan="11" align="center">Yes</td>
        </tr>
        <tr>
            <td>macOS Ventura 13.0</td>
        </tr>
        <tr>
            <td>macOS Monterey 12.0</td>
        </tr>
        <tr>
            <td>macOS Big Sur 11.0</td>
        </tr>
        <tr>
            <td>macOS Catalina 10.15</td>
            <td rowspan="10" align="center">x86_64</td>
        </tr>
        <tr>
            <td>macOS Mojave 10.14</td>
        </tr>
        <tr>
            <td>macOS High Sierra 10.13</td>
        </tr>
        <tr>
            <td>macOS Sierra 10.12</td>
        </tr>
        <tr>
            <td>OS X El Capitan 10.11</td>
        </tr>
        <tr>
            <td>OS X Yosemite 10.10</td>
        </tr>
        <tr>
            <td>OS X Mavericks 10.9</td>
        </tr>
        <tr>
            <td>Mac OS X Mountain Lion 10.8</td>
            <td rowspan="3" align="center">
              Not Yet<br>
              <sub>(should work)</sub>
            </td>
        </tr>
        <tr>
            <td>Mac OS X Lion 10.7</td>
        </tr>
        <tr>
            <td>Mac OS X Snow Leopard 10.6</td>
        </tr>
    </tbody>
</table>

<h2>Planned Changes</h2>
<ul>
   <li>
      📁 <strong>Add support for the individual partitions selection</strong><br>
         <sub>
           This will allow you to choose the destination device not only from the list of ‘whole’ disks, but also the individual partitions of your USB drive or any internal disk.
         </sub>
   </li>
  <br>
   <li>
      🔍  <strong>Add toggle to show internal drives</strong><br>
         <sub>
           Although this operation can cause potential data loss if enabled by mistake, it can still be a very convenient option for some users who want to install Microsoft Windows without using any USB drives.
         </sub>
   </li>
  <br>
   <li>
      🗜 <strong>Add support for splitting install.esd (compressed system image) files</strong><br>
         <sub>
           Some Windows .iso’s, (usually repacks) use .esd system images for the best compression.<br>
           But there can be some situations where even the .esd file is too large to fit into FAT32 partitions.<br>
           At this moment, only install.wim images can be split. Splitting .esd requires wimlib to be updated.
         </sub>
   </li>
  <br>
   <li>
      💻 <strong>Add support for the 32-bit Macs</strong><br>
      <sub>
        At this time, you can only use WinDiskWriter on x86_64 / ARM64 Mac computers.<br>
        Since this software has the minimum Mac OS X requirements of Snow Leopard 10.6, it is possible to compile a 32-bit build.<br>
        But I can’t do it right now, since this kind of build operation isn’t supported on Apple Silicon.
      </sub>
   </li>
  <br>
   <li>
      📝 <strong>Implement a feature that allows to add a custom ei.cfg</strong><br>
         <sub>
           This feature will allow users to select the Windows edition of their choice, regardless of the ACPI SLIC configuration.
         </sub>
   </li>
  <br>
   <li>
      🌐 <strong>Implement a feature that allows to skip the online account requirement from Windows 11 22H2+</strong><br>
         <sub>
           This feature will allow users to skip the requirement for signing in to their Microsoft Account on the install stage.<br>
         For now, since this feature isn't implemented, users can use <strong><em>OOBE</em>\BYPASSNRO</strong>
         </sub>
   </li>
  <br>
   <li>
      🎨 <strong>Resolve UI drawing issues on Mac OS X Mavericks 10.9 and lower</strong><br>
         <sub>
           There are some UI drawing issues on some older Mac OS X versions due to different behaviour of some system views.<br>
           It’s not critical at all, and it doesn’t affect anything, except the visuals.
         </sub>
   </li>
</ul>

<h2>Additional Information</h2>
<p>
   This software is written in <b>Objective-C</b>, a programming language that allows it to run on <b>many versions of macOS</b>, from <b>Snow Leopard 10.6</b> to <b>Sonoma 14.0</b>. Objective-C is a powerful and efficient language that combines object-oriented and dynamic features with the C language.<br><br>
   <b>WinDiskWriter</b> uses <b>wimlib</b>, a library for manipulating Windows Imaging (WIM) files, to perform operations such as splitting, patching, and extracting. I would like to thank the developers of wimlib for their amazing work and contribution to the open source community.<br><br>
   <b>WinDiskWriter</b> also uses <b>grub4dos</b>, a bootloader that can boot from various devices and formats, to enable Legacy BIOS booting for Windows images. I would like to thank the developers of grub4dos for their great work and support. Grub4dos is not embedded into the WinDiskWriter binary, but it is included in the app resources. The user is free to modify, remove, or delete the grub4dos binaries at any time.
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

<h2>Used External Software</h2>
<ul>
    <li>
      <a href="https://wimlib.net/">wimlib</a> <sub><sup><a href="https://github.com/TechUnRestricted/windiskwriter/blob/main/libs/wimlib/License.txt">(GNU LESSER GENERAL PUBLIC LICENSE Version 3)</a></sup></sub>
    </li>
  <li>
      <a href="https://github.com/chenall/grub4dos">grub4dos</a> <sub><sup><a href="https://github.com/chenall/grub4dos/blob/0.4.6a/COPYING">(GNU GENERAL PUBLIC LICENSE Version 2)</a><br>
        (This software isn't built into the WinDiskWriter binary.
        It's distributed as a separate binary in a Resources folder.
        <b>The user is free to modify, replace or remove the binaries at any time</b>.)</sup></sub>
    </li>
</ul>

