using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class TallGrayView : MonoBehaviour
{
    public event Action onWitGainEffect = delegate { };
    private float _valueToChange;
    Material _myMaterial;
    [SerializeField] Animator _myAnimator;
    [SerializeField] private Coroutine dissolveCoroutine;
    private SkinnedMeshRenderer skinned;
    [SerializeField]
    private Material dissolveMaterial;
    [SerializeField]
    private Material sphereEffectMaterial;
    [SerializeField]
    private ParticleSystem _hitEffect;
    [SerializeField]
    private ParticleSystem _deathEffect;
    [SerializeField]
    private ParticleSystem _pepperEffect;
    [SerializeField]
    private ParticleSystem _poisonEffect;
    [SerializeField]
    private ParticleSystem _witGainEffect;
    [SerializeField]
    private GameObject _hitWave;
    private AudioSource _as;
    void Start()
    {
        _poisonEffect.Stop();
        _witGainEffect.gameObject.SetActive(false);
        skinned = GetComponentInChildren<SkinnedMeshRenderer>();
        _myAnimator = GetComponent<Animator>();
        _as = GetComponent<AudioSource>();
        GameVars.Values.soundManager.AddAudioSource(_as);
    }

    public void EndSpawnAnim()
    {
        _myAnimator.SetBool("IsSpawning", false);
    }

    public void WalkAnimation(bool value)
    {
        PlaySoundCrackles();
        _myAnimator.SetBool("IsWalking", value);
    }

    public void AttackAnimation(bool value)
    {
        //_myAnimator.PlayInFixedTime("Attack");
        //_myAnimator.Play("Attack");
        _myAnimator.SetBool("IsAttacking", value);
    }

    public void DeathAnimation()
    {
        GameVars.Values.soundManager.PlaySoundOnce(_as, "SFX_TallGray_DeathSound", 0.4f, true);
        _myAnimator.SetBool("IsDead", true);
    }

    public void HitAnimation()
    {
        _myAnimator.Play("Hit");
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
    public void CatGrabAnimation(bool value)
    {
        _myAnimator.SetBool("IsGrab", value);
    }

    public void DissolveAnimation()
    {
        StartCoroutine(PlayShaderDissolve());
    }

    public void InnerEffectAnimation()
    {
        _hitEffect.Play();
        _hitWave.SetActive(!_hitWave.activeSelf);
        _hitWave.GetComponent<Animator>().SetBool("IsHit", true);
    }
    public void PoisonHit()
    {
        _poisonEffect.Play();
    }
    public void ActivateWitGainEffect()
    {
        onWitGainEffect();
        _witGainEffect.gameObject.SetActive(true);
        _witGainEffect.Play();
    }
    public void Dead()
    {
        Destroy(gameObject);
    }
    public void PlaySoundCrackles()
    {
        GameVars.Values.soundManager.PlaySound(_as, "SFX_TallGray_Walking", 0.35f, true, 1f);
    }
    public void PlaySoundCoinWitGain()
    {
        ActivateWitGainEffect();
        GameVars.Values.soundManager.PlaySound(_as, "CoinSFX", 0.45f, false, 1f);
        GameVars.Values.WaveManager.SubstractEnemyFromAmountInScene();
    }
    #region Shaders
    public void SwitchDissolveMaterial(Material material)       
    {
        var materials = skinned.sharedMaterials.ToList();
        materials.Clear();
        materials.Add(material);
        skinned.sharedMaterials = materials.ToArray();
    }

    IEnumerator LerpScaleDissolve(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            skinned.material.SetFloat("_ScaleDissolveGray", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
    }

    IEnumerator PlayShaderDissolve()
    {
        _deathEffect.Stop();
        SwitchDissolveMaterial(dissolveMaterial);
        dissolveCoroutine = StartCoroutine(LerpScaleDissolve(0f, 1f));
        yield return new WaitForSeconds(1.5f);
        Dead();
    }

    internal void PoisonHitStop()
    {
        _poisonEffect.Stop();
    }

    #endregion
}
