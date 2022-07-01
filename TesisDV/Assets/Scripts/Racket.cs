using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Racket : Melee
{
    [SerializeField]
    private ParticleSystem _trail;
    private bool hitStateActive;
    private bool _isDestroyed;
    private bool _isHitted;
    public delegate void OnRacketDestroyedDelegate(bool destroyed);
    public event OnRacketDestroyedDelegate OnRacketDestroyed;
    public delegate void OnRacketHitDelegate(bool hit);
    public event OnRacketHitDelegate OnRacketHit;
    // Start is called before the first frame update
    void Awake()
    {
        hitsRemaining = 7;
        //OnRacketInventoryRemoved += _player.RacketInventoryRemoved;
        //_trail = GetComponentInChildren<ParticleSystem>();
        //anim = transform.parent.GetComponent<Animator>();
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
                _isHitted = true;
                hitsRemaining--;
                if (hitsRemaining <= 0)
                {
                    _isDestroyed = true;
                    GameVars.Values.soundManager.PlaySoundAtPoint("RacketBroken", transform.position, 0.09f);
                    GameVars.Values.ShowNotification("Oh no! The racket has broken!");
                    OnRacketDestroyed?.Invoke(_isDestroyed);
                    _player.RacketInventoryRemoved();
                }
                //OnRacketHit?.Invoke(_isHitted);
                //OnRacketHit += other.gameObject.GetComponent<Gray>().RacketHit;
                //_isHitted = false;
                AddObserver(other.gameObject.GetComponent<Gray>());
                TriggerHit("RacketHit");
            }
        }
    }
    
}
