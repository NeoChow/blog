Changes at a Glance
===================

When I worked at Garmin, their software was made up of many different modules developed by many different groups. This fostered an environment where each little module was delivered almost like its own product to other teams.

Product teams needed a way to quickly determine whether or not to pull the latest code from a technology team. This came down to a few key factors. Was there a functionality change that would have a higher chance of introducing instability or possibly an API change requiring integration? Were there important bug fixes? Did the technology integrate newer versions of other technologies that could cause dependency issues?

To make this process easier I developed a commit prefix system. The general concept is to categorize every commit by adding a short prefix making it easy to glance through a commit history and get an overview of the type of changes made. I have evolved it over the last few years and I think it is something that would be useful for the greater software community. I have nicknamed it Changes at a Glance or **CAAG** for short. My latest iteration of it has the following format:

> [AA] Change summary
>
> Extended description of change

Where AA is one of the following two letter prefixes:

<table>
    <tr>
        <th>Prefix</th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td>FC</td>
        <td>Functionality Change</td>
        <td>Changes to the functionality of the app</td>
    </tr>
    <tr>
        <td>CI</td>
        <td>Code Improvement</td>
        <td>Changes to the format of the code or repository that do not affect the app in any way</td>
    </tr>
    <tr>
        <td>OP</td>
        <td>Optimization</td>
        <td>Change that improves the performance of the app without changing its functionality</td>
    </tr>
    <tr>
        <td>DU</td>
        <td>Dependency Update</td>
        <td>An update to or addition of a dependency</td>
    </tr>
    <tr>
        <td>RE</td>
        <td>Release</td>
        <td>An change that marks the app as being at a newer version</td>
    </tr>
</table>

The idea is to not only make repository histories easier to use, but also to encourage developers to better focus their changes. Every change should fit within one and only one of the aforementioned categories. If it seems like a change fits into more than one category, it is a good sign that the change should be split into multiple changes. If the change doesnt fit into any categories, is it a change worth making?

If you think this system would be useful I would love if you began using it in your own repositories and help me continue to evolve it. I believe it is a great way to make third party libraries more accessible.
