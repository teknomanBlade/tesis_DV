using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class CatView : MonoBehaviour
{
    [SerializeField] Animator _myAnimator;
    [SerializeField] AudioSource _as;
    public bool IsPlayedOnce;

    void Start()
    {
        _myAnimator = GetComponent<Animator>();
        _as = GetComponent<AudioSource>();
        IsPlayedOnce = true;
    }

    public void IdleAnim()
    {
        IsPlayedOnce = true;
        _myAnimator.SetBool("IsIdle", true);
        _myAnimator.SetBool("IsWalking", false);
        _myAnimator.SetBool("IsRunning", false);
        _myAnimator.SetBool("IsMad", false);
    }
     
    public void WalkAnim()
    {
        GameVars.Values.soundManager.StopSound(_as);

        if (IsPlayedOnce)
            GameVars.Values.soundManager.PlaySoundAtPoint("SFX_CatMeowingToBasement", transform.position, 0.2f);

        _myAnimator.SetBool("IsMad", false);
        _myAnimator.SetBool("IsWalking", true);
        _myAnimator.SetBool("IsIdle", true);
        _myAnimator.SetBool("IsRunning", false);
        IsPlayedOnce = false;
    }
    public void TakenAnim()
    {
        GameVars.Values.soundManager.PlaySound(_as, "SFX_AngryCat", 1f,true, 1f);

        _myAnimator.SetBool("IsMad", true);
        _myAnimator.SetBool("IsWalking", false);
        _myAnimator.SetBool("IsRunning", false);
        _myAnimator.SetBool("IsIdle", true);
    }
    public void RunningAnim()
    {
        GameVars.Values.soundManager.StopSound(_as);
        _myAnimator.SetBool("IsRunning", true);
        _myAnimator.SetBool("IsMad", false);
    }
}
