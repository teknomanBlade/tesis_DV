using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Racket : Melee
{
    [SerializeField]
    private ParticleSystem _trail;
    private MeshRenderer _renderer;
    private bool hitStateActive;
    [SerializeField]
    private bool _isDestroyed;
    public delegate void OnRacketDestroyedDelegate(bool destroyed);
    public event OnRacketDestroyedDelegate OnRacketDestroyed;
    public Texture textureState1;
    public Texture textureState2;
    public Texture textureState3;
    // Start is called before the first frame update
    void Awake()
    {
        hitsRemaining = 7;
        SetStateRacketDamaged(hitsRemaining);
        _renderer = GetComponent<MeshRenderer>();
    }

    public void OnNewRacketGrabbed()
    {
        _isDestroyed = false;
        hitsRemaining = 7;
        OnRacketDestroyed?.Invoke(_isDestroyed);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void MeleeAttack()
    {
        if(!IsAttacking)
            StartCoroutine(Attack("IsAttacking","RacketSwing"));
    }
    IEnumerator Attack(string param, string name)
    {
        IsAttacking = true;
        _player.Cam.ShakeRacketSwing();
        _trail.gameObject.SetActive(IsAttacking);
        _trail.Play();
        anim.SetBool(param, true);
        GameVars.Values.soundManager.PlaySoundAtPoint("RacketSwing", transform.position, 0.09f);

        var clips = anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        anim.SetBool(param, false);
        _trail.Stop();

        IsAttacking = false;
        hitStateActive = false;
        _trail.gameObject.SetActive(IsAttacking);
    }

    protected override void OnContactEffect(Collider other)
    {
        if (IsAttacking)
        {
            if (other.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                //Debug.Log("Hit WITH RACKET TO GRAY?" + other.transform.name);
                hitsRemaining--;
                SetStateRacketDamaged(hitsRemaining);
                if (hitsRemaining <= 0)
                {
                    _isDestroyed = true;
                    GameVars.Values.soundManager.PlaySoundAtPoint("RacketBroken", transform.position, 0.09f);
                    GameVars.Values.ShowNotification("Oh no! The racket has broken!");
                    OnRacketDestroyed?.Invoke(_isDestroyed);
                    _player.RacketInventoryRemoved();
                }
                AddObserver(other.gameObject.GetComponent<Gray>());
                TriggerHit("RacketHit");
            }
        }
    }

    public void SetStateRacketDamaged(int hitsRemaining)
    {
        if (hitsRemaining == 5)
        {
            Debug.Log("HITS 5");
            _renderer.material.SetTexture("_MainTexture", textureState1);
        }
        else if (hitsRemaining == 3)
        {
            Debug.Log("HITS 3");
            _renderer.material.SetTexture("_MainTexture", textureState2);
        }
        else if (hitsRemaining == 1)
        {
            Debug.Log("HITS 1");
            _renderer.material.SetTexture("_MainTexture", textureState3);
        }
    }
    
}
