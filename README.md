<h1>WinDiskWriter</h1>

<p>
&emsp;&emsp;<b>WinDiskWriter</b> - an application for macOS that allows you to write flash drives with <b>Microsoft Windows</b> using a macOS-based computer.<br>
&emsp;&emsp;This software is <b>free</b> and <b>open source</b>, and you can <strong>support me</strong> by <strong><a href="#%EF%B8%8F-support-me-%EF%B8%8F-donations">making a donation</a></strong>.<br>
</p>

<p align="center">
  <img width="420" alt="WinDiskWriter Main Screen" src="https://github.com/TechUnRestricted/windiskwriter/assets/83237609/ab8fd7bf-8be0-487b-a48e-c6809e558d99">
</p>

<p>
&emsp;&emsp;You can choose between a user-friendly <b>graphical interface</b> or a powerful <b>console</b> version, depending on your preference and skill level.<br>
&emsp;&emsp;WinDiskWriter is <i>still in development</i>, so if you encounter any issues or have any questions, please <i>feel free to create an Issue on GitHub</i> and I will do my best to help you.</p>

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
            <td rowspan="8" align="center">Yes</td>
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
            <td rowspan="999" align="center">
              Not Yet<br>
              <sub>(should work)</sub>
            </td>
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
Only <b>UEFI x86_64</b> images are currently supported.<br>
Images with install.<b>esd</b> (compressed system image) over 4GB are not supported yet on FAT32, but install.<b>wim</b> works fine with every size.<br>
<i>Legacy Boot Mode and install.<b>esd</b> support is <b>coming soon</b>.</i>
</sup>

<h2>Additional Information</h2>
<p align="center">
  <img width="340" alt="WinDiskWriter About Screen" src="https://github.com/TechUnRestricted/windiskwriter/assets/83237609/1ab35bfb-de9c-434d-b5f0-859847c299a7">
</p>
<p>
&emsp;&emsp;WinDiskWriter is developed in the <b>Objective-C</b> programming language to ensure <b>maximum backward compatibility</b> with older versions of macOS.<br>
&emsp;&emsp;For building the interface, a custom solution was developed, which is an alternative to NSStackView, but for old operating systems.<br>
&emsp;&emsp;The interface supports setting minimum and maximum widths and heights of elements, which would simply be impossible to implement through .xib or .storyboard.<br>
&emsp;&emsp;The application <b>does not have any external dynamically-linked additional helpers</b>, so its functionality is guaranteed even if you run the application binary file separately.<br>
&emsp;&emsp;Since WinDiskWriter was written in Objective-C, which is supported from the very first version of Mac OS X, the <b>size of the application is very small</b>, while it contains several architectures (x86_64 and ARM64).
</p>

<h2>Todo</h2>
<ul>
  <li>
    Add support for Legacy BIOS booting.
  </li>
  <li>
    Add support for choosing individual partitions in WinDiskWriter (GUI).
  </li>
  <li>
    Add "Show internal drives" toggle.
  </li>
  <li>
    Add support for bypassing Windows 11 install requirements on unsupported hardware.
  </li>
  <li>
    Add support for splitting install.<b>esd</b> (compressed system image) files for FAT32 filesystem.
  </li>
  <li>
    Fix UI bugs on Mac OS X Mavericks 10.9 and lower.
  </li>
  <li>
    Add 32-Bit CPU support for the already existing fat binary. (x86_64 + ARM64 + x86)
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

