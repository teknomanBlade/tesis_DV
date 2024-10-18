using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextCinematicYouLoseAnim : MonoBehaviour
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

    public void CallYouLoseTextAnimation() 
    {
        Animator.SetBool("IsAllOtherAnimFinished", true);
    }
}
