using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayView : MonoBehaviour
{
    Material _myMaterial;
    Animator _myAnimator;

    [SerializeField]
    private Material dissolveMaterial;
    [SerializeField]
    private Material sphereEffectMaterial;
    [SerializeField]
    private ParticleSystem _hitEffect;
    [SerializeField]
    private ParticleSystem _deathEffect;

    void Start()
    {
        _myMaterial = GetComponent<Renderer>().material;
        _myAnimator = GetComponent<Animator>();
    }

    public void WalkAnimation(bool value)
    {
        _myAnimator.SetBool("IsWalking", true);
    }

    public void DeathAnimation()
    {
        _myAnimator.SetBool("IsDead", true);
    }

    public void HitAnimation()
    {
        _myAnimator.Play("Hit");
    }

}
