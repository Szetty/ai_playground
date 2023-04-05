use rust_bert::pipelines::common::ModelType;
use rust_bert::pipelines::summarization::{SummarizationConfig, SummarizationModel};
use rust_bert::pipelines::translation::{Language, TranslationConfig, TranslationModel};
use rust_bert::resources::RemoteResource;
use rust_bert::t5::{T5ConfigResources, T5ModelResources, T5VocabResources};
use rustler::{Env, ResourceArc, Term};
use std::sync::Mutex;
use tch::Device;

fn load(env: Env, _: Term) -> bool {
    rustler::resource!(Context, env);
    true
}

pub struct Context {
    pub translation_model: Mutex<TranslationModel>,
    pub summarization_model: Mutex<SummarizationModel>,
}

#[rustler::nif]
pub fn init() -> Result<ResourceArc<Context>, String> {
    let translation_model = init_translation_model()?;
    let summarization_model = init_summarization_model()?;

    let context = Context {
        translation_model: Mutex::new(translation_model),
        summarization_model: Mutex::new(summarization_model),
    };

    Ok(ResourceArc::new(context))
}

#[rustler::nif]
pub fn translate_en_to_ro(context: ResourceArc<Context>, text: String) -> Result<String, String> {
    match context.translation_model.try_lock() {
        Ok(translation_model) => {
            match translation_model.translate(&[text], Language::English, Language::Romanian) {
                Ok(results) => {
                    let result = results.get(0);
                    match result {
                        Some(value) => Ok(value.to_string()),
                        None => Err("Did not get any result".to_string()),
                    }
                }
                Err(error) => Err(format!(
                    "Got error when trying to translate: {}",
                    error.to_string(),
                )),
            }
        }
        Err(_) => Err("Could not lock mutex for translation model".to_string()),
    }
}

#[rustler::nif]
pub fn summarize(context: ResourceArc<Context>, text: String) -> Result<String, String> {
    match context.summarization_model.try_lock() {
        Ok(summarization_model) => {
            let results = summarization_model.summarize(&[text]);

            let result = results.get(0);
            match result {
                Some(value) => Ok(value.to_string()),
                None => Err("Did not get any result".to_string()),
            }
        }
        Err(_) => Err("Could not lock mutex for summarizer model".to_string()),
    }
}

fn init_translation_model() -> Result<TranslationModel, String> {
    let model_resource = RemoteResource::from_pretrained(T5ModelResources::T5_BASE);
    let config_resource = RemoteResource::from_pretrained(T5ConfigResources::T5_BASE);
    let vocab_resource = RemoteResource::from_pretrained(T5VocabResources::T5_BASE);

    let source_languages = [Language::English];
    let target_languages = [Language::Romanian];

    let translation_config = TranslationConfig::new(
        ModelType::T5,
        model_resource,
        config_resource,
        vocab_resource,
        None,
        source_languages,
        target_languages,
        Device::cuda_if_available(),
    );

    match TranslationModel::new(translation_config) {
        Ok(model) => Ok(model),
        Err(error) => Err(format!(
            "Got error when initializing translation model: {}",
            error.to_string(),
        )),
    }
}

fn init_summarization_model() -> Result<SummarizationModel, String> {
    let model_resource = RemoteResource::from_pretrained(T5ModelResources::T5_BASE);
    let config_resource = RemoteResource::from_pretrained(T5ConfigResources::T5_BASE);
    let vocab_resource = RemoteResource::from_pretrained(T5VocabResources::T5_BASE);

    let summarization_config = SummarizationConfig::new(
        ModelType::T5,
        model_resource,
        config_resource,
        vocab_resource,
        None, // Device::cuda_if_available(),
    );

    match SummarizationModel::new(summarization_config) {
        Ok(model) => Ok(model),
        Err(error) => Err(format!(
            "Got error when initializing summarization model: {}",
            error.to_string(),
        )),
    }
}

rustler::init!(
    "Elixir.AIPlayground.RustAI",
    [init, translate_en_to_ro, summarize],
    load = load
);
