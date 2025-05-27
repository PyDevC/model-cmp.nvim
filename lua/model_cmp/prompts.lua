SyntaxError = "Either use lsp to get the error or treesitter"

return {
    AutoComplete = "Predict 10 instances for this current line of code to autocomplete the text",
    PosFeedback = {
        type = "No issues",
        feedback = "The predictions you made were correct keep the format same."
    },
    NegFeedback = {
        type = { "Bug", "Wrong Prediction", "Gebrish", "Syntax Error", "Hallucination" },
        feedback = {
            "You just created a bug in my code",
            "You just predicted the wrong text try again with this new code sample",
            "You are not even trying to predict its some random nonsense",
            "Synatx Error:" .. SyntaxError .. " Fix this error in new prediction with new sample",
            "You are making up the stuff, try again with some new predictions"
        }
    }
}
