using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CatCinematicYouLose : MonoBehaviour
{
    
    public delegate void OnFinishCatAnimDelegate();
    public event OnFinishCatAnimDelegate OnFinishCatAnim;
    public Animator Animator;
    public AudioSource Audio;
    // Start is called before the first frame update
    void Awake()
    {
        Audio = GetComponent<AudioSource>();
        Audio.Play();
        Animator = GetComponent<Animator>();
        Animator.SetBool("IsAbducted",true);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    internal void CallFinishAnim()
    {
        OnFinishCatAnim?.Invoke();
        Animator.enabled = false;
    }
}
