# Delicious to Evernote
[Delicious](http://del.icio.us/) has gone to the dogs. [Evernote](http://evernote.com)'s free plan works great for bookmarking. This utility converts exported Delicious bookmarks into a format that can be imported into Evernote.

## Instructions
1. Export your Delicious bookmarks
  * Open *Profile > Settings > Export*
  * Ensure *Include My Tags* and *Include My Notes* are checked
  * Select *Export* to download your Delicious bookmarks export file

2. Convert your Delicious bookmarks into Evernote bookmarks
  * Install Ruby - I used version **2.4.3** (2.4 or later should work, earlier versions probably won't)
  * Clone this repo:
    ```
    git clone https://github.com/nzkeith/delicious-to-evernote.git
    ```
  * Open a shell in the repo folder and run:
    ```
    gem install bundler
    bundle install
    bundle exec ruby delicious_to_evernote.rb
    ```
    This will say `Success!` and not show any errors if everything's set up correctly
  * Copy your Delicious bookmarks export file into the repo folder
  * Edit `delicious_to_evernote.rb` to set `$in_filename` to the filename of your export file
  * In the command shell, do another:
    ```
    bundle exec ruby delicious_to_evernote.rb
    ```
    This creates the Evernote bookmarks import file `Evernote.enex`

3. Import your Evernote bookmarks
  * Download and install the Evernote application (I used the Windows client)
  * Open *File > Import > Evernote Export Files...*
  * Select the `Evernote.enex` bookmarks import file
