using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SWEP_FingerGun : MonoBehaviour, ISWEP
{
    public Player _player;
    private GameObject _swepModel;
    private GameObject _projectile;

    public void OnEquip(Player player)
    {
        _player = player;
        _swepModel = GameVars.Values.WEP_FingerGun;
        _swepModel.SetActive(true);
        _projectile = GameVars.Values.WEP_FingerGun_Projectile;
    }

    public void Interaction()
    {
        throw new System.NotImplementedException();
    }

    public void PrimaryFire()
    {
        GameObject aux = Instantiate(_projectile, _player.GetCameraPosition(), _player.transform.rotation);
        aux.GetComponent<Rigidbody>().AddForce(_player.GetCameraForward() * 25f, ForceMode.Impulse);
    }

    public void SecondaryFire()
    {
        throw new System.NotImplementedException();
    }

    public void OnUnequip()
    {
        _swepModel.SetActive(false);
    }
}
