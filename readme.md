#Further exercises: paparazzi

Groups are encouraged but not required for this exercise.

Write a sinatra server that does the following without the aid of JS:
- at '/' renders a form with one text input for a tag name and a submit button. 
- When the user enters a word and clicks the button, the server should send a request to instagram's api using [this gem](https://github.com/jnunemaker/httparty) for all pictures with that word as a tag. 
- The server should then render at most 10 pictures from instagram on a show page. 
- There should be a save button next to each picture; if a user clicks the save button, save the image url in a database. 
- Amend '/' so any saved pictures appear below the form.

Bonus: 
- Add a delete button to each image in the list of saved images that, when clicked, removes that image from the page and the database
- Allow the user to save multiple selections at once on the show page.
- Add a checkbox labeled 'location' next to your tag input. If the user checks the box before submitting, assume that their entry is now a location instead of a tag. Return images based on that location.
- When a location is entered, have the background color of the image show page reflect the current weather conditions of the location entered.