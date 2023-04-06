# Drawboard, but without the suck

this repo contains old versions of drawboard pdf, which are still usable. the latest version of drawboard is a steaming pile of garbage, and i'm not the only one who thinks so. this repo is a collection of old versions of drawboard pdf, which are still usable. i'll try to keep it up to date, but i can't promise anything. (i'm not affiliated with drawboard in any way, i just really hate the new version.)

## Is this safe??

all the msixbundle files are digitally signed (right click any file, then select the tab 'digital signatures' to validate), so you can be sure that they're not tampered with.
the signer certificate was issued by "Entrust.net", which seems to be a trusted certificate authority, and issued to "Drawboard Pty Ltd".
this means that whoever (i assume it's drawboard) signed the files got the people at entrust to verify that they belong to a company called "Drawboard Pty Ltd", which is THE drawboard company.

so, yes, this should be safe.

> Note: they've changed their certificate in version 6.30.8, but the above still applies.

## Why are there so many versions?

because i've downloaded them all, before drawboard decided to remove the old versions from their website.

## Why do the bundles get so big after 6.30.8?

this one is actually quite interesting!

it's coperate greed. they want to make more money, so they moved more and more tools to their paid "Pro Upgrade" plan.
But paid features require promotion (in the form of a preview), so they started including those in **every** version of drawboard from that version on.
and they're not just a few megabytes, they're **hundreds of megabytes**. And they're getting bigger and bigger with every update.

From this, we can also see what features they wish to promote the most (sorting by file size):

1. Cloud Storage (34 MB; was partially free before)
2. Tool Slots (23 MB; free before)
3. Multiple Windows (23 MB; actually new, i think)
4. Signatures (18 MB; free before)
5. Pressure Sensitive Inking (13 MB; free before)

In the latest version i've downloaded, the previews for the "Pro Upgrade" add about 180MB to every architecture (x86, x64, arm), so that's 540MB of bloat for every version.

If you don't believe me, just download and unpack the latest version (eg. with 7zip) and look under `/Assets/Brand/ProUpgrade/` for yourself.


Also, they've somehow managed to completely destroy the quality of those (added) previews. Somehow they managed to have compression artifacts __and__ increase the file size at the same time. I don't know how they did it, but it's kinda impressive.

# Why?

because with the latest updates, drawboard now sucks :(

# The Tool

scan & download all available versions from the appinstaller version of drawboard available at https://www.drawboard.com/drawboard-pdf-msix-download.

## How?

when you inspect the appinstaller file, you'll notice that all resources are hosted in a (public!) azure blob store.
the links to the main drawboard.msixbundle (we dont care about dependencies) are present in the following format: `https://dbpdfusprodmsixstorage.blob.core.windows.net/downloads/Db.App_$($Version)/Db.App_$($Version)_x86_x64_ARM.msixbundle`

just generating urls for all version numbers\* that could be possible (literally going 6.37.1.0, 6.37.0.0, ...) and sending a HEAD request to each of them will quickly reveal which versions are actually available. Nicely, azure returns a 404 if the file is not found, so you can just check the status code of the response.

from there, you can just download the msixbundle from the url like you normally would, or use the `azcopy` utility to be a bit quicker about it.

> \* the version numbers are in the format `Major.Minor.Build.Revision`. generating them is a bit tricky, since drawboard isn't exactly consistent with their version numbers...
