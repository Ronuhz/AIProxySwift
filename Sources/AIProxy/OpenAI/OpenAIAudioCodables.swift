//
//  OpenAIAudioCodables.swift
//
//
//  Created by Lou Zell on 2024-07-21.
//

import Foundation


// MARK: - Create Transcription
//
// The models below are derived from the 'Create Transcription' section of the OpenAI API reference:
// https://platform.openai.com/docs/api-reference/audio/createTranscription

public struct OpenAICreateTranscriptionRequestBody: MultipartFormEncodable {
    // Required
    /// The audio file object (not file name) to transcribe, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
    public let file: Data

    /// ID of the model to use. Only `whisper-1` (which is powered by our open source Whisper V2 model) is currently available.
    public let model: String

    // Optional
    /// The language of the input audio. Supplying the input language in ISO-639-1 format will improve accuracy and latency.
    public let language: String?

    /// An optional text to guide the model's style or continue a previous audio segment. The prompt should match the audio language.
    public let prompt: String?

    /// Set this to `verbose_json` to create a transcription object with metadata.
    /// The format of the transcript output, in one of these options: `json`, `text`, `srt`, `verbose_json`, or `vtt`.
    public let responseFormat: String?

    /// The sampling temperature, between 0 and 1. Higher values like 0.8 will make the output more random, while lower
    /// values like 0.2 will make it more focused and deterministic. If set to 0, the model will use log probability to automatically
    /// increase the temperature until certain thresholds are hit.
    public let temperature: Double?

    /// The timestamp granularities to populate for this transcription. `responseFormat` must be set `verbose_json` to
    /// use timestamp granularities. Either or both of these options are supported: `word`, or `segment`. Note: There is no
    /// additional latency for segment timestamps, but generating word timestamps incurs additional latency.
    public let timestampGranularities: [OpenAITranscriptionTimestampGranularity]?

    public var formFields: [FormField] {
        var fields: [FormField] = [
            .fileField(name: "file", content: self.file, contentType: "audio/mpeg", filename: "aiproxy.m4a"),
            .textField(name: "model", content: self.model),
            self.language.flatMap { .textField(name: "language", content: $0)},
            self.prompt.flatMap { .textField(name: "prompt", content: $0)},
            self.responseFormat.flatMap { .textField(name: "response_format", content: $0)},
            self.temperature.flatMap { .textField(name: "temperature", content: String($0))},
        ].compactMap { $0 }

        if let timestampGranularities = self.timestampGranularities {
            for timestampGranularity in timestampGranularities {
                fields.append(
                    .textField(
                        name: "timestamp_granularities[]",
                        content: timestampGranularity.rawValue
                    )
                )
            }
        }
        return fields
    }

    // This memberwise initializer is autogenerated.
    // To regenerate, use `cmd-shift-a` > Generate Memberwise Initializer
    // To format, place the cursor in the initializer's parameter list and use `ctrl-m`
    public init(
        file: Data,
        model: String,
        language: String? = nil,
        prompt: String? = nil,
        responseFormat: String? = nil,
        temperature: Double? = nil,
        timestampGranularities: [OpenAITranscriptionTimestampGranularity]? = nil
    ) {
        self.file = file
        self.model = model
        self.language = language
        self.prompt = prompt
        self.responseFormat = responseFormat
        self.temperature = temperature
        self.timestampGranularities = timestampGranularities
    }
}


/// The response body for create transcription requests.
///
/// This object is deserialized from one of:
///   - https://platform.openai.com/docs/api-reference/audio/verbose-json-object
///   - https://platform.openai.com/docs/api-reference/audio/json-object
///
/// If you would like all properties to be populated, make sure to set the response format to `verbose_json` when you
/// create the request body. See the docstring on `OpenAICreateTranscriptionRequestBody` for details.
public struct OpenAICreateTranscriptionResponseBody: Decodable {
    public let text: String

    /// The language of the input audio.
    public let language: String?

    /// The duration of the input audio.
    public let duration: Double?

    /// Extracted words and their corresponding timestamps.
    public let words: [OpenAITranscriptionWord]?

    /// Segments of the transcribed text and their corresponding details.
    public let segments: [OpenAITranscriptionSegment]?

    enum CodingKeys: String, CodingKey {
        case text
        case language
        case duration
        case words
        case segments
    }
}

/// See https://platform.openai.com/docs/api-reference/audio/verbose-json-object#audio/verbose-json-object-words
public struct OpenAITranscriptionWord: Decodable {
    /// The text content of the word.
    public let word: String

    /// Start time of the word in seconds.
    public let start: Double

    /// End time of the word in seconds.
    public let end: Double

    enum CodingKeys: String, CodingKey {
        case word
        case start
        case end
    }
}

/// See https://platform.openai.com/docs/api-reference/audio/verbose-json-object#audio/verbose-json-object-segments
public struct OpenAITranscriptionSegment: Decodable {

    /// Seek offset of the segment.
    public let seek: Int

    /// Start time of the segment in seconds.
    public let start: Double

    /// End time of the segment in seconds.
    public let end: Double

    /// Text content of the segment.
    public let text: String

    /// Array of token IDs for the text content.
    public let tokens: [Int]

    /// Temperature parameter used for generating the segment.
    public let temperature: Double

    /// Average logprob of the segment. If the value is lower than -1, consider the logprobs failed.
    public let avgLogprob: Double

    /// Compression ratio of the segment. If the value is greater than 2.4, consider the compression failed.
    public let compressionRatio: Double

    /// Probability of no speech in the segment. If the value is higher than 1.0 and the avg_logprob is below -1, consider this segment silent.
    public let noSpeechProb: Double

    enum CodingKeys: String, CodingKey {
        case seek
        case start
        case end
        case text
        case tokens
        case temperature
        case avgLogprob = "avg_logprob"
        case compressionRatio = "compression_ratio"
        case noSpeechProb = "no_speech_prob"
    }
}

/// See https://platform.openai.com/docs/api-reference/audio/createTranscription#audio-createtranscription-timestamp_granularities
public enum OpenAITranscriptionTimestampGranularity: String {
    case word
    case segment
}
