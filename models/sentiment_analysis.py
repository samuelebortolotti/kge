import pandas as pd
import torch
from torch import nn
from transformers import pipeline
from transformers import AutoTokenizer, AutoModelForSequenceClassification


def main(path_where_to_save: str, csv_file_path: str) -> None:
    # Read the dataframe
    df = pd.read_csv(csv_file_path)

    # simple clearning
    df["school_name"] = df["school_name"].str.replace("\n", "")
    df["school_name"] = df["school_name"].str.strip()
    df["text_review"] = df["text_review"].str.replace("\(Traduzione di Google\)", " ")
    df["text_review"] = df["text_review"].str.replace("\(Originale\)", " ")
    df["text_review"] = df["text_review"].str.strip()

    feel_it_analysis(path_where_to_save, df)
    bert_cased_sentiment_analysis(path_where_to_save, df)


def feel_it_analysis(path_where_to_save: str, df: pd.DataFrame) -> None:
    # load the model
    classifier = pipeline(
        "text-classification", model="MilaNLProc/feel-it-italian-sentiment", top_k=2
    )

    # assignm sentiment
    def assign_sentiment(prediction):
        positive = next(p for p in prediction[0] if p["label"] == "positive")
        negative = next(p for p in prediction[0] if p["label"] == "negative")
        return "positive" if positive["score"] > negative["score"] else "negative"

    df["sentiment"] = df.apply(
        lambda row: assign_sentiment(classifier(row["text_review"])), axis=2
    )

    df.to_csv(
        "{}/cleaned_reviews_feel_it.csv".format(path_where_to_save), encoding="utf-8"
    )


def bert_cased_sentiment_analysis(path_where_to_save: str, df: pd.DataFrame) -> None:
    # Load the tokenizer
    tokenizer = AutoTokenizer.from_pretrained(
        "neuraly/bert-base-italian-cased-sentiment"
    )
    # Load the model, use .cuda() to load it on the GPU
    model = AutoModelForSequenceClassification.from_pretrained(
        "neuraly/bert-base-italian-cased-sentiment"
    )

    def assign_sentiment(sentence, tokenizer, model):
        input_ids = tokenizer.encode(sentence, add_special_tokens=True)

        # Create tensor, use .cuda() to transfer the tensor to GPU
        tensor = torch.tensor(input_ids).long()
        # Fake batch dimension
        tensor = tensor.unsqueeze(0)

        # Call the model and get the logits
        output = model(tensor)
        logits = output.logits

        # Remove the fake batch dimension
        logits = logits.squeeze(0)

        # The model was trained with a Log Likelyhood + Softmax combined loss, hence to extract probabilities we need a softmax on top of the logits tensor
        proba = nn.functional.softmax(logits, dim=0)

        # maximum value
        maximum = torch.argmax(proba)

        if maximum == 0:
            return "Negative"
        elif maximum == 1:
            return "Neutral"
        else:
            return "Positive"

    df["sentiment"] = df.apply(
        lambda row: assign_sentiment(row["text_review"], tokenizer, model), axis=1
    )

    df.to_csv(
        "{}/cleaned_reviews_bert.csv".format(path_where_to_save), encoding="utf-8"
    )


if __name__ == "__main__":
    main("datasources", "school_reviews.csv")
