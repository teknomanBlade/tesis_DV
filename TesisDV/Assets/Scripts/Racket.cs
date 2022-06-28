using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Racket : Melee
{
    [SerializeField]
    private ParticleSystem _trail;
    // Start is called before the first frame update
    void Awake()
    {
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
        _trail.gameObject.SetActive(IsAttacking);
    }
    /*public IEnumerator Attack()
    {
        IsAttacking = true;
        anim.SetBool("IsAttacking", true);
        yield return new WaitForSeconds(1f);
        TriggerHit("RacketHit");
        anim.SetBool("IsAttacking", false);
        IsAttacking = false;
    }*/

    protected override void OnContactEffect(Collider other)
    {
        if (IsAttacking)
        {
            if (other.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                //Debug.Log("Hit WITH RACKET TO GRAY?" + other.transform.name);
                AddObserver(other.gameObject.GetComponent<Gray>());
                TriggerHit("RacketHit");
            }
        }
    }
}
