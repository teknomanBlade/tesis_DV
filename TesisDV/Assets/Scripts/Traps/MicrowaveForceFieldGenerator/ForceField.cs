using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceField : Trap
{
    [SerializeField] private float _health;
    public float Health { get { return _health; } set { _health = value; } }
    [SerializeField] private MicrowaveForceFieldGenerator _myOwner;
    void Awake()
    {
        _myOwner = transform.parent.GetComponent<MicrowaveForceFieldGenerator>();
        active = true;
        Health = 20f;
    }

    public void TakeDamage(float damageAmount)
    {
        Health -= damageAmount;
        if (Health <= 0f)
        {
            active = false;
            _myOwner.Inactive();
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
