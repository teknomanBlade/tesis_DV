using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class SoundManager : MonoBehaviour
{
    //public List<AudioClip> AudioClips;
    private List<AudioClip> AudioClips;
    private Dictionary<string, AudioClip> SoundLibrary { get; set; }
    private AudioSource _sound;
    private AudioClip clip;
    // Start is called before the first frame update
    void Awake()
    {
        SoundLibrary = new Dictionary<string, AudioClip>();
        _sound = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {

    }
    public SoundManager SetAudioClips(List<AudioClip> audioClips)
    {
        AudioClips = audioClips;
        AudioClips.ForEach(x => SoundLibrary.Add(x.name, x));
        return this;
    }

    public void PlaySoundOnce(string clipName, float volume, bool loop)
    {
        if (SoundLibrary.TryGetValue(clipName, out clip))
        {
            _sound.clip = clip;
            _sound.volume = volume;
            _sound.loop = loop;
            _sound.spatialBlend = 0f;
            _sound.PlayOneShot(clip);
        }
    }

    public void PlaySoundOnce(AudioSource sound, string clipName, float volume, bool loop)
    {
        if (SoundLibrary.TryGetValue(clipName, out clip))
        {
            sound.clip = clip;
            sound.volume = volume;
            sound.loop = loop;
            sound.spatialBlend = 0f;
            sound.PlayOneShot(clip);
        }
    }

    public void PlaySound(string clipName, float volume, bool loop)
    {
        if (SoundLibrary.TryGetValue(clipName, out clip))
        {
            _sound.clip = clip;
            _sound.volume = volume;
            _sound.loop = loop;
            _sound.spatialBlend = 0f;
            _sound.Play();
        }
    }

    public void PlaySound(AudioSource sound, string clipName, float volume, bool loop, float spatialBlend)
    {
        if (SoundLibrary.TryGetValue(clipName, out clip))
        {
            sound.clip = clip;
            sound.volume = volume;
            sound.loop = loop;
            sound.minDistance = 2f;
            sound.maxDistance = 400f;
            sound.spatialBlend = spatialBlend;
            sound.Play();
        }
    }


    public void PlaySoundAtPoint(string clipName, Vector3 position, float volume)
    {
        if (SoundLibrary.TryGetValue(clipName, out clip))
        {
            AudioSource.PlayClipAtPoint(clip, position, volume);
        }
    }
    public float GetClipLength(string clipName) 
    {
        if (SoundLibrary.TryGetValue(clipName, out clip))
        {
            return clip.length;
        }
        return 0f;
    }

    public void StopSound(AudioSource audioSource)
    {
        if (audioSource.isPlaying)
        {
            audioSource.Stop();
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
