using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    //public List<AudioClip> AudioClips;
    private List<AudioClip> AudioClips;
    private Dictionary<string, AudioClip> soundLibrary;
    private AudioSource _sound;
    private AudioClip clip;
    // Start is called before the first frame update
    void Awake()
    {
        soundLibrary = new Dictionary<string, AudioClip>();
        _sound = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {

    }
    public SoundManager SetAudioClips(List<AudioClip> audioClips)
    {
        AudioClips = audioClips;
        AudioClips.ForEach(x => soundLibrary.Add(x.name, x));
        return this;
    }

    public void PlaySoundOnce(string clipName, float volume, bool loop)
    {
        if (soundLibrary.TryGetValue(clipName, out clip))
        {
            _sound.clip = clip;
            _sound.volume = volume;
            _sound.loop = loop;
            _sound.PlayOneShot(clip);
        }
    }

    public void PlaySound(string clipName, float volume, bool loop)
    {
        if (soundLibrary.TryGetValue(clipName, out clip))
        {
            _sound.clip = clip;
            _sound.volume = volume;
            _sound.loop = loop;
            _sound.Play();
        }
    }

    public void PlaySoundAtPoint(string clipName, Vector3 position, float volume)
    {
        if (soundLibrary.TryGetValue(clipName, out clip))
        {
            AudioSource.PlayClipAtPoint(clip, position, volume);
        }
    }

    public void StopSound()
    {
        if (_sound.isPlaying)
        {
            _sound.Stop();
        }
    }
}
