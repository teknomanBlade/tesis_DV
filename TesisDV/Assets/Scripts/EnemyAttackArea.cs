using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAttackArea : MonoBehaviour
{
    [SerializeField]
    private Enemy _myOwner;
    [SerializeField] private int _damageAmount;
    public delegate void OnAttackPlayerPositionDelegate(Vector3 attackPos, bool attacked);
    public event OnAttackPlayerPositionDelegate OnAttackPlayerPosition;
    void Start()
    {
        _myOwner = transform.parent.GetComponent<Enemy>();
    }

    void OnTriggerEnter(Collider other)
    {
        var player = other.GetComponent<Player>();

        if (player)
        {
            OnAttackPlayerPosition += player.OnAttackPlayerPosition;
            OnAttackPlayerPosition(_myOwner.transform.position, true);
            player.Damage(_damageAmount, _myOwner);   
        }

        var forceField = other.GetComponent<ForceField>();

        if (forceField)
        {
            if (forceField.IsDamageReturn) 
            {
                _myOwner.TakeDamage(forceField.DamageReturnAmount);
            }
            forceField.TakeDamage(_damageAmount);
        }
    }
}
