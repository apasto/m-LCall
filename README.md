# m-LCall

## Deprecation note

While implementing this, I noticed that Python package [stripy](https://pypi.org/project/stripy/), with its bundled `litho1pt0` interface, does a WAY BETTER job at this task than I was attempting to.

Anyway, this has been a nice exercise and in my opinion there is no point in... hiding it :)

## Description

Matlab functions to parse the plaintext output of the access utility of LITHO1.0 (Pasyanos, Masters, Laske, & Ma (2014), [doi: 10.1002/2013JB010626](https://doi.org/10.1002/2013JB010626)) and import it in Matlab on regularly sampled meshgrids.

## Disclaimer
I am not affiliated with, nor endorsed by, the aforementioned Authors of the LITHO1.0 model.
This is a tool to parse the output of the provided model-querying utility (access_litho) and translate it into different data structures.
No part of the model or of access_litho is included in this repository.

I do not guarantee that the model integrity is conserved by my functions - it is very likely that some re-sampling artefacts are introduced.

## Prerequisites

The GetProfile function performs a system call to `access_litho` and parses its plaintext output.
You must have downloaded the model and compiled `acccess_litho`, as available in the [LITHO1.0 website](https://igppweb.ucsd.edu/~gabi/litho1.0.html) (`litho1.0.tar.gz` in the download section).

There are no dependencies to additional MATLAB® toolboxes. Tested on MATLAB 2018b.

Should be OCTAVE-compatible, but this was not tested for.

## Installing

Add the repository folder (the one that this README is in) to your MATLAB® path.
The contents of './+LCall' will be then available as a 'package directory'.

`LCall.` must be prefixed to the called function.

Example:

```matlab
LCall.GetProfile(lat,lon,path)
```

## Using

### GetProfile

Call directly **LCall.GetProfile** to get the parsed output of a profile query at a point.

```text
Usage: [Depths,Rhos,Vp,Vs,(Names)] = LCall.GetProfile(lat,lon,BinPath)
           Depths, Rhos, Names are complete to a 10-layer model
           suitable to obtain a depth- and Rho-map for each layer
           including missing (=zero-thickness) ones

Input: lat       : scalar, latitude (deg)
       lon       : scalar, longitude (deg)
       BinPath : string, path to access_litho, including trailing (back)slash

Output: Depths  : depth in metres for each layer, positive downwards
        Rhos    : density in kg/m3 for each layer, AIR rho set to 0
        Vp      : Vp in m/s for each layer, AIR Vp set to 0
        Vs      : Vs in m/s for each layer, AIR Vs set to 0
        (names) : optional, name of each layer
```

### MakeMaps

Use **LCall.MakeMaps** to run GetProfile on a regular grid, obtaining layer depths, densities and velocities.

```text
Usage: [Lat,Lon,DepthMap,RhoMap,VpMap,VsMap] = LCall.MakeMaps(LatRange,LonRange,step)

Input: LatRange : latitude range, as [lat min, lat max]
                      degrees [-90,90] increasing
       LonRange : longiture range, as [lon min, lon max]
                      degrees [-180,180] increasing
       step     : step between nodes, degrees

       (note: 1 point only and Lon-only/Lat-only profiles are fine)

Output: Lat, Lon : Lat, Lon vectors
        DepthMap : (Lon,Lat,Layer) array of depths in metres (positive downwards)
        RhoMap   : (Lon,Lat,Layer) array of densities in kg/m3
        VpMap    : (Lon,Lat,Layer) array of Vp, in m/s
        VsMap    : (Lon,Lat,Layer) array of Vs, in m/s
```

## Authors

- **Alberto Pastorutti** - [github.com/apasto](https://github.com/apasto)

## License

This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details.

<sup>MATLAB® is a registered trademark of The MathWorks, Inc.</sup>
