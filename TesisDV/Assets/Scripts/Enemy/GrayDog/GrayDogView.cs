using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayDogView : MonoBehaviour
{
    [SerializeField] Animator _myAnimator;
    [SerializeField]
    private ParticleSystem _hitEffect;
    [SerializeField]
    private GameObject _hitWave;
    // Start is called before the first frame update
    void Start()
    {
        _myAnimator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void InnerEffectAnimation()
    {
        _hitEffect.Play();
        _hitWave.SetActive(!_hitWave.activeSelf);
        _hitWave.GetComponent<Animator>().SetBool("IsHit", true);
    }
    public void EndSpawnAnim()
    {
        _myAnimator.SetBool("IsSpawning", false);
    }

    public void DeathAnimation()
    {
        _myAnimator.SetBool("IsDead", true);
    }

    public void HitAnimation()
    {
        _myAnimator.SetBool("IsHitted",true);
    }

    public void RunningAnimation()
    {
        _myAnimator.SetBool("IsRunning", true);
    }

    public void CatGrabAnimation(bool value)
    {

    }
}
