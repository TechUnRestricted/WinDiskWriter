<h1>WinDiskWriter</h1>

<p>
&emsp;&emsp;<b>WinDiskWriter</b> - an application for macOS that allows you to write flash drives with <b>Microsoft Windows</b> using a macOS-based computer.<br>
&emsp;&emsp;This software is <b>free</b> and <b>open source</b>, and you can <strong>support me</strong> by <strong><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">making a donation</a></strong>.<br>
</p>

<p align="center">
  <img width="420" alt="WinDiskWriter Main Screen" src="https://i.postimg.cc/xQwFTxnf/Win-Disk-Writer-Main-Screen.png">
</p>

<p>
&emsp;&emsp;You can enjoy a <b>user-friendly graphical interface</b> that makes the process easy and intuitive.<br>
&emsp;&emsp;WinDiskWriter is <i>still in development</i>, so if you encounter any issues or have any questions, please <i>feel free to create an Issue on GitHub</i> and I will do my best to help you.
</p>

<h2>Features</h2>
<ul>
  <li>
    Creating bootable USB drives for Windows Vista to 11.
  </li>
  <li>
    Patching Windows 11 Installer in order to remove hardware restrictions (TPM chip and Secure Boot requirements).
  </li>
  <li>
    Extracting the UEFI-compatible bootloader from the Windows Vista or 7 installation file.
  </li>
  <li>
    Splitting a large install.wim file into multiple .swm files to comply with the FAT32 file size limit.
  </li>
</ul>

<h2>Compatibility</h2>
<h3>macOS Support</h3>
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

<h3>Windows Images</h3>
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

<sup>
  <b>UEFI x86_64</b> images are the only supported format at the moment.<br>
  Images with install.<b>esd</b> (compressed system image) larger than 4GB are not compatible with FAT32, but install.<b>wim</b> works well with any size.<br>
  <i>Support for Legacy Boot Mode and large install.<b>esd</b> files is <b>under development</b>.</i>
</sup>

<h2>Additional Information</h2>
<p align="center">
  <img width="340" alt="WinDiskWriter About Screen" src="https://i.postimg.cc/SkDr8DFz/Win-Disk-Writer-About-Screen.png">
</p>
<p>
&emsp;&emsp;WinDiskWriter is developed in the <b>Objective-C</b> programming language to ensure <b>maximum backward compatibility</b> with older versions of macOS.<br>
&emsp;&emsp;The application <b>can be run as a standalone binary</b> that does not depend on any external dynamic libraries, ensuring its functionality even when executed on its own.<br>
&emsp;&emsp;Using this language, which is supported by all versions of Mac OS X, WinDiskWriter achieves a <b>compact application size</b>, despite containing multiple architectures (x86_64 and ARM64).

</p>

<h2>Planned Features</h2>
<ul>
  <li>
    Enable Legacy BIOS booting option.
  </li>
  <li>
    Allow selecting individual partitions in WinDiskWriter (GUI).
  </li>
  <li>
    Provide a toggle to show internal drives.
  </li>
  <li>
    Support splitting install.<b>esd</b> (compressed system image) files for FAT32 filesystem compatibility.
  </li>
  <li>
    Resolve UI Elements drawing issues on Mac OS X Mavericks 10.9 and lower.
  </li>
  <li>
    Add 32-Bit CPU support for the existing fat binary. (x86_64 + ARM64 + x86).
  </li>
</ul>

<h2>❤️ Support Me ❤️ (Donations)</h2>
<ul>
  <li>
    Bitcoin (BTC): <b>bc1qe2z68uwgplxfzspdy5pnxhzza2spep0ryk5zeq</b>
  </li>
  <li>
    Etherium (ETH): <b>0x1410acAc3e0De885f4fb8C305a2F7B586d47c5ff</b>
  </li>
  <li>
    BNB Beacon Chain (BNB): <b>bnb1h2svmvj9842xk49qjflza4q8yqn2kd9dsxp9h9</b>
  </li>
  <li>
    Tether USD [USDT] (ERC20): <b>0x1410acAc3e0De885f4fb8C305a2F7B586d47c5ff</b>
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

