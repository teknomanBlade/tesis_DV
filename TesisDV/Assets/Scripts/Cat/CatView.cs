using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class CatView : MonoBehaviour
{
    [SerializeField] Animator _myAnimator;

    void Start()
    {
        _myAnimator = GetComponent<Animator>();
    }

    public void IdleAnim()
    {
        _myAnimator.SetBool("IsIdle", true);
        _myAnimator.SetBool("IsWalking", false);
        _myAnimator.SetBool("IsMad", false);
        _myAnimator.SetBool("IsRunning", false);
    }

    public void WalkAnim()
    {
        _myAnimator.SetBool("IsWalking", true);
        _myAnimator.SetBool("IsIdle", false);
        _myAnimator.SetBool("IsMad", false);
        _myAnimator.SetBool("IsRunning", false);
    }
    public void TakenAnim()
    {
        _myAnimator.SetBool("IsMad", true);
        _myAnimator.SetBool("IsIdle", false);
        _myAnimator.SetBool("IsWalking", false);
        _myAnimator.SetBool("IsRunning", false);
    }
    public void RunningAnim()
    {
        _myAnimator.SetBool("IsMad", false);
        _myAnimator.SetBool("IsIdle", false);
        _myAnimator.SetBool("IsRunning", true);
        _myAnimator.SetBool("IsWalking", false);
    }
}
