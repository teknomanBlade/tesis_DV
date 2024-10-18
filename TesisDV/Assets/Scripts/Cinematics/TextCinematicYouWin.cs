using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextCinematicYouWin : MonoBehaviour
{
    public Animator Animator;
    void Awake()
    {
        Animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void CallYouWinTextAnimation()
    {
        Animator.SetBool("IsUFOAnimFinished", true);
    }
}
