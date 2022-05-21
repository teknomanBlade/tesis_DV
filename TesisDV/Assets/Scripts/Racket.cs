using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Racket : Melee
{
    public Animator anim;
    // Start is called before the first frame update
    void Awake()
    {
        anim = transform.parent.GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void MeleeAttack()
    {
        StartCoroutine(Attack());
    }

    public IEnumerator Attack()
    {
        anim.SetBool("IsAttacking", true);
        yield return new WaitForSeconds(1f);
        anim.SetBool("IsAttacking", false);
    }

    protected override void OnContactEffect(Collider other)
    {
        if (effectUp)
        {
            Debug.Log("Hit " + other.transform.name);
            if (other.gameObject.layer.Equals(GameVars.Values.GetEnemyLayer()))
            {
                effectUp = false;
                AddObserver(other.gameObject.GetComponent<Gray>());
                TriggerHit("RacketHit");
            }
        }
    }
}
