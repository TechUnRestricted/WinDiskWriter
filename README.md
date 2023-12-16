<h1>WinDiskWriter</h1>

<p align="center">
  <a href="https://github.com/TechUnRestricted/windiskwriter/releases"><img src="https://i.postimg.cc/X3tS32rs/Artboard.jpg"/></a>
</p>

<p align="center">
  <a href="https://github.com/TechUnRestricted/windiskwriter/blob/main/license.md">
    <img alt="License" src="https://img.shields.io/github/license/TechUnReStricted/windiskwriter">
  </a>

  <a href="https://github.com/TechUnRestricted/windiskwriter/releases">
    <img alt="Releases" src="https://img.shields.io/github/downloads/TechUnRestricted/windiskwriter/total">
  </a>
<a href="https://app.fossa.com/projects/git%2Bgithub.com%2FTechUnRestricted%2Fwindiskwriter?ref=badge_shield" alt="FOSSA Status"><img src="https://app.fossa.com/api/projects/git%2Bgithub.com%2FTechUnRestricted%2Fwindiskwriter.svg?type=shield"/></a>
  
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

<h2 align="center">Windows USB Disk Creator for macOS</h2>

<pre align="center">
  💖 Hey there! If you like my work, please <b><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">support me financially!</a></b> 💖
</pre>

You can use this app to create bootable universal USB <strong>Windows installers</strong> that supports both <strong>UEFI</strong> and <strong>Legacy BIOS</strong> modes.<br>
With this USB drive, you can install and enjoy <strong>Windows</strong> on your <strong>PC</strong>, <strong>Intel Mac</strong> or certain <strong>Virtual Machines</strong>.

<center>
  <img alt="WinDiskWriter Main Window" src="https://i.postimg.cc/CFYbxwkD/Win-Disk-Writer-Main-Wind-w.png">
</center>

<h2>Table of Contents</h2>
<b>
<ol>
  <li><a href="#features">Features</a></li>
  <li><a href="#compatibility">Compatibility</a>
    <ol>
      <li><a href="#-supported-windows-images">💻 Supported Windows Images</a></li>
      <li><a href="#-supported-macos-versions">🍏 Supported macOS Versions</a></li>
    </ol>
  </li>
  <li><a href="#planned-changes">Planned Changes</a></li>
  <li><a href="#additional-information">Additional Information</a></li>
  <li><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">❤️ Support Me ❤️ (Donations)</a></li>
  <li><a href="#authors">Authors</a></li>
  <li><a href="#software-used">Software Used</a></li>
</ol>
</b>

<h2>Features</h2>
<ul>
   <li>
     📀 <strong>Create bootable USB Windows installers with ease</strong><br>
      <sub>
        WinDiskWriter knows how to write a USB for each Windows Image type.
      </sub>
   </li>
  <br>
   <li>
     🛠 <strong>Patch Windows 11 Installer</strong><br>
      <sub>
        You can bypass TPM, Minimum RAM, Secure Boot and some other System Requirements set by Microsoft for Windows 11.<br>
        Just click <strong>Patch Installer Requirements</strong> before writing.
      </sub>
   </li>
  <br>
   <li>
     👾 <strong>Legacy BIOS Support</strong><br>
      <sub>
        You can create an all-in-one USB drive that supports both <strong>UEFI</strong> and <strong>Legacy</strong> boot modes.<br>
        It&#39;s required if you want to install Windows on computers with <strong>older firmware</strong> that doesn&#39;t support EFI booting.
      </sub>
   </li>
  <br>
   <li>
     🔐 <strong>Add EFI Support to Legacy Windows Versions</strong><br>
      <sub>
        Windows Vista and 7 don&#39;t support EFI booting out of the box.<br>
        Additional steps are required to get these versions to boot on EFI, such as extracting a EFI-capable bootloader from the installer. <strong>WinDiskWriter does it for you!</strong>
      </sub>
   </li>
  <br>
   <li>
     🗂 <strong>Split Windows Installer Image</strong><br>
      <sub>
        Newer Windows ISOs contain a large (<strong>&gt;4GB</strong>) install.wim file.<br>
        Since FAT32 only supports file sizes up to 4GB, WinDiskWriter <strong>automatically splits it for you!</strong>
      </sub>
   </li>
</ul>

<h2>Compatibility</h2>
<h3>💻 Supported Windows Images</h3>
<table>
    <thead>
        <tr>
            <th>Version</th>
            <th>Architecture</th>
            <th>Boot Mode</th>
            <th>Verified?</th>
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
            <th>Verified?</th>
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
              <sub>(but it should work!)</sub>
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
      📁 <strong>Add support for selecting individual partitions</strong><br>
         <sub>
           This will allow you to choose the destination device not only from the list of ‘whole’ disks, but also the individual partitions of your USB drive or any internal disk.
         </sub>
   </li>
  <br>
   <li>
      🔍  <strong>Add toggle to show internal drives</strong><br>
         <sub>
           Although this could cause potential data loss if enabled by mistake, it's still a very convenient option for people who want to install Windows without using any USB drives.
         </sub>
   </li>
  <br>
   <li>
      🗜 <strong>Add support for splitting install.esd (compressed system image) files</strong><br>
         <sub>
           Some Windows ISOs, (usually repacks) use .esd system images for better compression.<br>
           But sometimes, even a .esd file is too large to fit into FAT32 partitions.<br>
           Right now, WinDiskWriter can only split install.wim images. Splitting .esd requires wimlib to be updated.
         </sub>
   </li>
  <br>
   <li>
      💻 <strong>Add support for 32-bit Macs</strong><br>
      <sub>
        Right now, you can only use WinDiskWriter on x86_64 / ARM64 Mac computers.<br>
        Since this software has the minimum Mac OS X requirements of Snow Leopard 10.6, it's possible to compile a 32-bit build.<br>
        But I can’t do it right now, since this kind of build operation isn’t supported on Apple Silicon.
      </sub>
   </li>
  <br>
   <li>
      📝 <strong>Implement a feature that allows adding a custom ei.cfg</strong><br>
         <sub>
           This feature will allow users to select the Windows edition of their choice, regardless of the ACPI SLIC configuration.
         </sub>
   </li>
  <br>
   <li>
      🌐 <strong>Implement a feature that allows to skip the online account requirement from Windows 11 22H2+</strong><br>
         <sub>
           This feature will allow users to skip the requirement for signing in to their Microsoft Account on the install stage.<br>
           Since this feature isn't implemented, use "<strong>OOBE/BYPASSNRO</strong>" by pressing Shift+F10 on the Microsoft Account login stage.
         </sub>
   </li>
  <br>
   <li>
      🎨 <strong>Resolve UI drawing issues on Mac OS X Mavericks 10.9 and lower</strong><br>
         <sub>
           There are some UI drawing issues on some older Mac OS X versions due to different behaviour of some system views.<br>
           It’s not critical at all, and it doesn’t affect functionality.
         </sub>
   </li>
</ul>

<h2>Additional Information</h2>
<p>
   This software is written in <b>Objective-C</b>, a programming language that allows it to run on <b>many versions of macOS</b>, from <b>Snow Leopard 10.6</b> to <b>Sonoma 14.0</b>. Objective-C is a powerful and efficient language that combines object-oriented and dynamic features with the C language.<br><br>
   <b>WinDiskWriter</b> uses <b>wimlib</b>, a library for manipulating Windows Image (WIM) files, to perform operations such as splitting, patching, and extracting. I would like to thank the developers of wimlib for their amazing work and contribution to the open source community.<br><br>
   <b>WinDiskWriter</b> also uses <b>grub4dos</b>, a bootloader that can boot from various devices and formats, to enable Legacy BIOS booting for Windows images. I would like to thank the developers of grub4dos for their great work and support.
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

<h2>Software Used</h2>
<ul>
    <li>
      <a href="https://wimlib.net/">wimlib</a> <sub><sup><a href="https://github.com/TechUnRestricted/windiskwriter/blob/main/libs/wimlib/License.txt">(GNU LESSER GENERAL PUBLIC LICENSE Version 3)</a></sup></sub>
    </li>
  <li>
      <a href="https://github.com/chenall/grub4dos">grub4dos</a> <sub><sup><a href="https://github.com/chenall/grub4dos/blob/0.4.6a/COPYING">(GNU GENERAL PUBLIC LICENSE Version 2)</a><br>
        (grub4dos isn't built into the WinDiskWriter binary.
        It's distributed as a separate binary in the .app Resources folder.
        <b>Feel free to modify, replace or remove the binaries at any time</b>!)</sup></sub>
    </li>
</ul>



[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FTechUnRestricted%2Fwindiskwriter.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FTechUnRestricted%2Fwindiskwriter?ref=badge_large)