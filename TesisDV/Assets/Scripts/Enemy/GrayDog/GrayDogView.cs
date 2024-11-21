using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayDogView : MonoBehaviour
{
    public event Action onWitGainEffect = delegate { };
    [SerializeField] Animator _myAnimator;
    [SerializeField]
    private ParticleSystem _hitEffect;
    [SerializeField]
    private ParticleSystem _pepperEffect;
    [SerializeField]
    private ParticleSystem _poisonEffect;
    [SerializeField]
    private ParticleSystem _ringWavesEffect;
    [SerializeField]
    private ParticleSystem _witGainEffect;
    [SerializeField]
    private GameObject _hitWave;
    private AudioSource _as;
    // Start is called before the first frame update
    void Start()
    {
        _as = GetComponent<AudioSource>();
        _myAnimator = GetComponent<Animator>();
        _myAnimator.SetBool("IsSpawning", true);
        _witGainEffect.gameObject.SetActive(false);
        _poisonEffect.Stop();
        _ringWavesEffect.Stop();
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
        GameVars.Values.soundManager.StopSound(_as);
        _myAnimator.SetBool("IsDead", true);
    }

    public void HitAnimation()
    {
        _myAnimator.SetBool("IsHitted",true);
    }
    public void ElectricDebuffAnimation()
    {
        _myAnimator.SetBool("IsElectricHitted", true);
    }
    public void PepperHitEffect()
    {
        _pepperEffect.Play();
    }
    public void PaintballHit()
    {
        _myAnimator.SetBool("IsPaintballHitted", true);
    }
    public void ActivateWitGainEffect()
    {
        onWitGainEffect();
        _witGainEffect.gameObject.SetActive(true);
        _witGainEffect.Play();
    }
    public void RunningAnimation()
    {
        GameVars.Values.soundManager.PlaySound(_as, "SFX_AlienDogGallop", 0.25f, true, 1f);
        
        _myAnimator.SetBool("IsRunning", true);
    }
    public void PlaySoundCoinWitGain()
    {
        ActivateWitGainEffect();
        GameVars.Values.soundManager.PlaySound(_as, "CoinSFX", 0.45f, false, 1f);
        GameVars.Values.WaveManager.SubstractEnemyFromAmountInScene();
    }
    public void CatGrabAnimation(bool value)
    {
        _ringWavesEffect.Play();
        _myAnimator.SetBool("IsCatGrabbed", value);
    }

    public void PoisonHit()
    {
        _poisonEffect.Play();
    }

    internal void PoisonHitStop()
    {
        _poisonEffect.Stop();
    }
}
