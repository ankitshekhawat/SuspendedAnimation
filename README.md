# Suspended Animation
A screensaver for macOS (10.13+) that pulls [Cinemagrpahs](https://en.wikipedia.org/wiki/Cinemagraph) from [Reddit](https://www.reddit.com/) to show as a screensaver.

![suspended animation](https://github.com/ankitshekhawat/SuspendedAnimation/raw/master/cine.gif)


Written in Swift 3 for macOS High Sierra (10.13+) or later. 

[Download from here](https://github.com/ankitshekhawat/SuspendedAnimation/releases) 

The screensaver creates a folder `~/Documents/cinemagraphs` for where it downloads GIFs and videos from the subreddits.

You can delete any of the downloaded files for the folder or add your own.
The folder can get really huge as GIFs take up large size. Will soon add mechanism to automatically delete old files 

### Options
- Background: Changes the background color
- Subreddits: `+` separated list of subreddits. Default is `cinemagraphs+perfectloops`
- Option to disable downloads
- Option to fit to screen or leave the gifs at original size (for Animations larger than the screen will be scaled down)
### Known issue
The first time the screen saver runs it may give an error or be blank as the Cinemagraphs folder is empty. Wait for cinema graphs to download or add your own.
### TODO
- Auto delete old files.
- Option to convert GIfs to MP4 to save space. 
- switch Animation after an interval
- Add Flixel as a source

### Credits
- [mirkofetter](https://github.com/mirkofetter/ScreenSaverMinimal) for Starter Template 
- [SWXMLHash](https://github.com/drmohundro/SWXMLHash)  for RSS parsing
- [powhu](https://github.com/powhu) for GIF2MP4 for GIF to MP4 conversion (not yet implemented) 
