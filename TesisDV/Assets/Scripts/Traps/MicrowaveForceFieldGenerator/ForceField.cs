using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceField : Trap
{
    public float Health;
    void Awake()
    {
        active = true;
        Health = 100f;
    }

    void Update()
    {
        
    }

    public void TakeDamage(float damageAmount)
    {
        Health -= damageAmount;
        if (Health <= 0f)
        {
            active = false;
            gameObject.SetActive(false);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        var gray = other.gameObject.GetComponent<GrayModel>();
        if (gray != null)
        {
            /* gray._movingSpeed = 0f;
            gray.ForceFieldRejection(); */
        }
        var grayMelee = other.gameObject.GetComponent<TallGrayModel>();
        if (grayMelee != null)
        {
            /* grayMelee._movingSpeed = 0f;
            grayMelee._fsm.ChangeState(EnemyStatesEnum.AttackTrapState); */
        }
    }
}
