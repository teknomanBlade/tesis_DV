using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Racket : Melee
{
    
    // Start is called before the first frame update
    void Awake()
    {
        //anim = transform.parent.GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void MeleeAttack()
    {
        if(!IsAttacking)
            StartCoroutine(Attack());
    }

    public IEnumerator Attack()
    {
        IsAttacking = true;
        anim.SetBool("IsAttacking", true);
        yield return new WaitForSeconds(1f);
        anim.SetBool("IsAttacking", false);
        IsAttacking = false;
    }

    protected override void OnContactEffect(Collider other)
    {
        if (IsAttacking)
        {
            if (other.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                Debug.Log("Hit WITH RACKET TO GRAY?" + other.transform.name);
                AddObserver(other.gameObject.GetComponent<Gray>());
                TriggerHit("RacketHit");
            }
        }
    }
}
