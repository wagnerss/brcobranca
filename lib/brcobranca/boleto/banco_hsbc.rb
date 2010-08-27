# Banco HSBC
class BancoHsbc < Brcobranca::Boleto::Base

  # Responsável por definir dados iniciais quando se cria uma nova intância da classe BancoBrasil
  def initialize(campos={})
    padrao={:carteira => "CNR", :banco => "399"}
    campos = padrao.merge!(campos)
    super(campos)
  end

  # Número sequencial utilizado para distinguir os boletos na agência
  def nosso_numero
    if self.data_vencimento.kind_of?(Date)
      self.codigo_servico = 4
      dia = self.data_vencimento.day.to_s.rjust(2,'0')
      mes = self.data_vencimento.month.to_s.rjust(2,'0')
      ano = self.data_vencimento.year.to_s[2..3]
      data = "#{dia}#{mes}#{ano}"

      numero_documento = "#{self.numero_documento.to_s}#{self.numero_documento.to_s.modulo11_9to2_10_como_zero}#{self.codigo_servico.to_s}"
      soma = numero_documento.to_i + self.conta_corrente.to_i + data.to_i
      numero = "#{numero_documento}#{soma.to_s.modulo11_9to2_10_como_zero}"
      numero
    else
      self.codigo_servico = 5
      numero_documento = "#{self.numero_documento.to_s}#{self.numero_documento.to_s.modulo11_9to2_10_como_zero}#{self.codigo_servico.to_s}"
      soma = numero_documento.to_i + self.conta_corrente.to_i
      numero = "#{numero_documento}#{soma.to_s.modulo11_9to2_10_como_zero}"
      numero
    end
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
   "#{self.nosso_numero}"
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
   "#{self.conta_corrente}"
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  def monta_codigo_43_digitos
    banco = self.banco.to_s.rjust(3,'0')
    valor_documento = self.valor_documento.limpa_valor_moeda.to_s.rjust(10,'0')
    convenio = self.convenio.to_s
    conta = self.conta_corrente.to_s.rjust(7,'0')

    # Montagem é baseada no tipo de carteira e na presença da data de vencimento
    if self.carteira == "CNR"
      if self.data_vencimento.kind_of?(Date)
        raise "numero_documento pode ser de no máximo 13 caracteres." if (self.numero_documento.to_s.size > 13)
        fator = self.data_vencimento.fator_vencimento
        dias_julianos = self.data_vencimento.to_juliano
        self.codigo_servico = 4
        numero_documento = self.numero_documento.to_s.rjust(13,'0')
        numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}#{conta}#{numero_documento}#{dias_julianos}2"
        numero.size == 43 ? numero : nil
      else
        nil
      end
    else
      nil
    end
  end

end