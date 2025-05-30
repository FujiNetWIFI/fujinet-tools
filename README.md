# fujinet-tools

Various cross-platform fujinet tools to use with a working Fujinet on a supported platform.

There are two main directories:

- pre_migration - go in here and treat this like the repo before things were organzied
- post_migration - this is a staging area where things are in the middle of a re-organization


The classic 'f' tools that manipulate the fujinet are in pre_migration/[platform]

The newer 'n' tools are in post_migration/network/nput|nload|nget

If you don't see a specific ftool or ntool for a given platform it does not exist yet.

F is for Fuijinet as the code manages the fujinet device itself. n is for network and the tool does things to files via the FujiNet network device.

Note the device specific directories are old, and source in them is being migrated to the general project folders, e.g. nget, nput.


Instructions for building can be found in [README-build.md](./README-build.md).
